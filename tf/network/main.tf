resource "aws_security_group" "lb_sg" {
  vpc_id = data.aws_vpc.private.id
  name   = "${var.project_name}-lb-sg"

  ingress {
    from_port   = var.load_balancer_port
    to_port     = var.load_balancer_port
    protocol    = "tcp"
    cidr_blocks = local.private_subnet_cidrs
  }

  egress {
    from_port   = var.ecs_container_port
    to_port     = var.ecs_container_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.private.cidr_block]
  }

  egress {
    from_port   = var.lambda_port
    to_port     = var.lambda_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.private.cidr_block]
  }
}

resource "aws_lb" "lb" {
  name               = "${var.project_name}-lb"
  internal           = true
  load_balancer_type = "application"

  enable_deletion_protection = false

  security_groups = [aws_security_group.lb_sg.id]
  subnets         = data.aws_subnets.private.ids

  enable_cross_zone_load_balancing = true
}

resource "aws_lb_target_group" "ecs_tg" {
  name     = "ecs-tg"
  port     = var.ecs_container_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.private.id

  target_type = "ip"

  health_check {
    interval            = 10
    path                = local.ecs_healthcheck_path
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = var.load_balancer_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

resource "aws_lb_target_group" "lambda_tg" {
  name        = "lambda-tg"
  port        = var.lambda_port
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.private.id
  target_type = "lambda"

  health_check {
    interval            = 10
    path                = local.lambda_healthcheck_path
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "lambda_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = local.lambda_listener_port
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lambda_tg.arn
  }
}

resource "aws_security_group" "api_gateway_vpc_link" {
  name        = "${var.project_name}-api-gateway-vpc-link-sg"
  description = "Security group for API Gateway VPC link"
  vpc_id      = data.aws_vpc.private.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = local.private_subnet_cidrs
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = local.private_subnet_cidrs
  }
}

resource "aws_apigatewayv2_vpc_link" "this" {
  name               = "${var.project_name}-vpc-link"
  subnet_ids         = data.aws_subnets.private.ids
  security_group_ids = [aws_security_group.api_gateway_vpc_link.id]
}

resource "aws_apigatewayv2_api" "this" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "ecs_integration" {
  api_id             = aws_apigatewayv2_api.this.id
  integration_type   = "HTTP_PROXY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.this.id
  integration_method = "ANY"
  integration_uri    = aws_lb_listener.ecs_listener.arn

  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.this.id
  integration_type   = "HTTP_PROXY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.this.id
  integration_method = "ANY"
  integration_uri    = aws_lb_listener.lambda_listener.arn

  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "ecs_route" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /ecs/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.ecs_integration.id}"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /lambda/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_cloudwatch_log_group" "api_gw_logs" {
  name              = "/apigateway/${var.project_name}-${var.vpc_link_api_stage_name}-logs"
  retention_in_days = 1
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.vpc_link_api_stage_name
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_logs.arn
    format = jsonencode({
      requestId          = "$context.requestId"
      ip                 = "$context.identity.sourceIp"
      requestTime        = "$context.requestTime"
      httpMethod         = "$context.httpMethod"
      routeKey           = "$context.routeKey"
      status             = "$context.status"
      protocol           = "$context.protocol"
      responseLength     = "$context.responseLength"
      integrationLatency = "$context.integrationLatency"
    })
  }
}
