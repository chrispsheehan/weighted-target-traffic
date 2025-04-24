resource "aws_security_group" "ecs_sg" {
  vpc_id = data.aws_vpc.private.id
  name   = local.ecs_security_group_name
}

resource "aws_security_group_rule" "ecs_ingress_from_lb" {
  type                     = "ingress"
  from_port                = var.ecs_container_port
  to_port                  = var.ecs_container_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_sg.id
  source_security_group_id = aws_security_group.lb_sg.id
  description              = "Allow ingress from the load balancer to the ECS container port"
}

resource "aws_security_group_rule" "ecs_egress_to_vpc" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_sg.id
  cidr_blocks       = [data.aws_vpc.private.cidr_block]
  description       = "Allow ECS to talk to VPC endpoints and internal services"
}

resource "aws_security_group" "lambda_sg" {
  vpc_id = data.aws_vpc.private.id
  name   = local.lambda_security_group_name
}

resource "aws_security_group_rule" "lambda_ingress_from_lb" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lambda_sg.id
  source_security_group_id = aws_security_group.lb_sg.id
  description              = "Allow ingress from the load balancer to the Lambda function on port range 0-65535"
}

resource "aws_security_group_rule" "lambda_egress_to_logs" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lambda_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow Lambda to send logs to CloudWatch Logs (HTTPS)"
}
resource "aws_security_group" "lb_sg" {
  vpc_id = data.aws_vpc.private.id
  name   = local.lb_security_group_name
}

resource "aws_security_group_rule" "lb_ingress_from_private_subnets" {
  type              = "ingress"
  from_port         = var.load_balancer_port
  to_port           = var.load_balancer_port
  protocol          = "tcp"
  security_group_id = aws_security_group.lb_sg.id
  cidr_blocks       = local.private_subnet_cidrs
  description       = "Allow ingress from private subnets to the ALB listener"
}

resource "aws_security_group_rule" "lb_egress_to_vpc" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.lb_sg.id
  cidr_blocks       = [data.aws_vpc.private.cidr_block]
  description       = "Limit outgoing traffic from ALB to VPC"
}
resource "aws_security_group" "api_gateway_vpc_link" {
  name        = local.vpc_link_security_group_name
  description = "Security group for API Gateway VPC link"
  vpc_id      = data.aws_vpc.private.id
}

resource "aws_security_group_rule" "vpc_link_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.api_gateway_vpc_link.id
  cidr_blocks       = local.private_subnet_cidrs
  description       = "Allow HTTP ingress from private subnets to API Gateway VPC Link"
}

resource "aws_security_group_rule" "vpc_link_egress_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.api_gateway_vpc_link.id
  cidr_blocks       = local.private_subnet_cidrs
  description       = "Allow HTTP egress from API Gateway VPC Link to private subnets"
}
