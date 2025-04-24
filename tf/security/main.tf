resource "aws_security_group" "ecs_sg" {
  vpc_id = data.aws_vpc.private.id
  name   = local.ecs_security_group_name

  ingress {
    description     = "allow ingress from the load balancer to the ecs container port"
    from_port       = 0
    to_port         = var.ecs_container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    description      = "allow ecs to access the internet"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "lambda_sg" {
  vpc_id = data.aws_vpc.private.id
  name   = local.lambda_security_group_name

  ingress {
    description     = "allow ingress from the load balancer to the lambda function"
    from_port       = 0
    to_port         = 0
    protocol        = -1
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    description      = "allow lambda to access the internet"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
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