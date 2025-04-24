resource "aws_security_group" "ecs_sg" {
  vpc_id = data.aws_vpc.private.id
  name   = local.ecs_security_group_name

  ingress {
    description     = "Allow ingress from the load balancer to the ecs container port"
    from_port       = var.ecs_container_port
    to_port         = var.ecs_container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    description = "Allow ECS to talk to VPC endpoints and internal services"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.private.cidr_block]
  }
}

resource "aws_security_group" "lambda_sg" {
  vpc_id = data.aws_vpc.private.id
  name   = local.lambda_security_group_name

  ingress {
    description     = "Allow ingress from the load balancer to the lambda function on lambda port 65535"
    from_port       = 0
    to_port         = 65535 
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    description = "Allow Lambda to send logs to CloudWatch Logs (HTTPS)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "lb_sg" {
  vpc_id = data.aws_vpc.private.id
  name   = local.lb_security_group_name

  ingress {
    from_port   = var.load_balancer_port
    to_port     = var.load_balancer_port
    protocol    = "tcp"
    cidr_blocks = local.private_subnet_cidrs
  }

  egress {
    description = "limit outgoing traffic to the VPC link"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.private.cidr_block]
  }
}

resource "aws_security_group" "api_gateway_vpc_link" {
  name        = local.vpc_link_security_group_name
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