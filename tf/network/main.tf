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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.private.cidr_block]
  }
}

resource "aws_lb" "lb" {
  name               = local.lb_name
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

resource "aws_lb_listener" "ecs_lambda_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = var.load_balancer_port
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Error: ALB Resource not found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "lambda_rule" {
  listener_arn = aws_lb_listener.ecs_lambda_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lambda_tg.arn
  }

  condition {
    path_pattern {
      values = ["/${var.vpc_link_api_stage_name}/lambda/*"]
    }
  }
}

resource "aws_lb_listener_rule" "ecs_rule" {
  listener_arn = aws_lb_listener.ecs_lambda_listener.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }

  condition {
    path_pattern {
      values = ["/${var.vpc_link_api_stage_name}/ecs/*"]
    }
  }
}

resource "aws_lb_target_group" "lambda_tg" {
  name        = "lambda-tg"
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

resource "aws_apigatewayv2_integration" "alb_integration" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "HTTP_PROXY"
  integration_uri  = "http://${aws_lb.lb.dns_name}"
  integration_method = "ANY"
}

resource "aws_apigatewayv2_route" "api_route" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.alb_integration.id}"
}

resource "aws_cloudwatch_log_group" "api_gw_logs" {
  name              = "/aws/apigateway/${var.project_name}-${var.vpc_link_api_stage_name}-logs"
  retention_in_days = var.log_retention_days
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
