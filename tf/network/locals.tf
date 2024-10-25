locals {
  private_subnet_cidrs = [for s in data.aws_subnet.subnets : s.cidr_block]
  lb_name              = "${var.project_name}-lb"
  healthcheck_path     = "/health"
  stage_weighted_paths = {
    for key, rule in var.path_rules : key => {
      ecs_percentage_traffic    = rule.ecs_percentage_traffic
      lambda_percentage_traffic = rule.lambda_percentage_traffic
      paths                     = [for path in rule.paths : "/${var.vpc_link_api_stage_name}/${path}"]
      priority                  = rule.priority
    }
  }
}