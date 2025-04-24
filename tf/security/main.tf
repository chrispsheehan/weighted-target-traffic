resource "aws_security_group" "ecs_sg" {
  vpc_id = data.aws_vpc.private.id
  name   = local.ecs_security_group_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ecs_ingress_from_lb" {
  type                     = "ingress"
  from_port                = var.ecs_container_port
  to_port                  = var.ecs_container_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_sg.id
  source_security_group_id = aws_security_group.lb_sg.id
  description              = "Allow ingress from the load balancer to the ECS container port"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ecs_egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow ECS to access public AWS services over HTTPS (e.g., ECR, CloudWatch)"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "lambda_sg" {
  vpc_id = data.aws_vpc.private.id
  name   = local.lambda_security_group_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "lambda_ingress_from_lb" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lambda_sg.id
  source_security_group_id = aws_security_group.lb_sg.id
  description              = "Allow ingress from the load balancer to the Lambda function on port range 0-65535"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "lambda_egress_to_logs" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lambda_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow Lambda to send logs to CloudWatch Logs (HTTPS)"

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group" "lb_sg" {
  vpc_id = data.aws_vpc.private.id
  name   = local.lb_security_group_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "lb_ingress_from_apigw_vpc_link" {
  type                     = "ingress"
  from_port                = var.load_balancer_port
  to_port                  = var.load_balancer_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb_sg.id
  source_security_group_id = aws_security_group.api_gateway_vpc_link.id
  description              = "Only allow ingress from API Gateway VPC Link"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "lb_egress_to_ecs" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb_sg.id
  source_security_group_id = aws_security_group.ecs_sg.id
  description              = "Allow egress to ECS target SG"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "lb_egress_to_lambda" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb_sg.id
  source_security_group_id = aws_security_group.lambda_sg.id
  description              = "Allow egress to Lambda target SG"

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group" "api_gateway_vpc_link" {
  name        = local.vpc_link_security_group_name
  description = "Security group for API Gateway VPC link"
  vpc_id      = data.aws_vpc.private.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "vpc_link_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.api_gateway_vpc_link.id
  cidr_blocks       = local.private_subnet_cidrs
  description       = "Allow HTTP ingress from private subnets to API Gateway VPC Link - THIS HAS NO AFFECT"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "vpc_link_egress_to_alb" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.api_gateway_vpc_link.id
  source_security_group_id = aws_security_group.lb_sg.id
  description              = "Allow HTTP egress from API Gateway VPC Link to ALB only"

  lifecycle {
    create_before_destroy = true
  }
}
