locals {
  private_subnet_cidrs    = [for s in data.aws_subnet.subnets : s.cidr_block]
  lambda_listener_port    = 80
  lambda_healthcheck_path = "/${var.vpc_link_api_stage_name}/lambda/health"
  ecs_healthcheck_path    = "/${var.vpc_link_api_stage_name}/ecs/health"
}