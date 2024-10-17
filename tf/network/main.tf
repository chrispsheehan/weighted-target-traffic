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
    from_port   = var.container_port
    to_port     = var.container_port
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
  name     = "${var.project_name}-tg"
  port     = var.container_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.private.id

  target_type = "ip"

  health_check {
    interval            = 10
    path                = "/health"
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
  name        = "${var.project_name}-lambda-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.private.id
  target_type = "lambda"
}

resource "aws_lb_listener" "lambda_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
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
  route_key = "ANY /ecs/{proxy+}"  # Routes matching /ecs/ path
  target    = "integrations/${aws_apigatewayv2_integration.ecs_integration.id}"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /lambda/{proxy+}"  # Routes matching /lambda/ path
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "ecs_stage" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "ecs"
  auto_deploy = true
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.api_stage_name
  auto_deploy = true
}
