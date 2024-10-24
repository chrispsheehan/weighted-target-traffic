locals {
  private_subnet_cidrs = [for s in data.aws_subnet.subnets : s.cidr_block]
  lb_name              = "${var.project_name}-lb"
  healthcheck_path     = "/health"
  weighted_paths       = [for path in var.weighted_paths : "/${var.vpc_link_api_stage_name}/${path}"]
  ecs_only_paths       = [for path in var.ecs_only_paths : "/${var.vpc_link_api_stage_name}/${path}"]
  lambda_only_paths    = [for path in var.lambda_only_paths : "/${var.vpc_link_api_stage_name}/${path}"]
}