locals {
  private_subnet_cidrs = [for s in data.aws_subnet.subnets : s.cidr_block]
  ecs_listener_port    = 3000
  lambda_listener_port = 4000
}