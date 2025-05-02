locals {
  lb_name                      = "${var.project_name}-lb"
  healthcheck_path             = "/health"
  lb_security_group_name       = "${var.project_name}-lb-sg"

  default_weighting_with_percentages = {
    ecs_percentage_traffic    = var.default_weighting == "ecs" ? 100 : 0
    lambda_percentage_traffic = var.default_weighting == "lambda" ? 100 : 0
  }

  rule_keys = sort(keys(var.weighted_rules))
  weighted_rules_with_priority = {
    for idx, key in local.rule_keys : key => {
      ecs_percentage_traffic    = var.weighted_rules[key] == "ecs" ? 100 : 0
      lambda_percentage_traffic = var.weighted_rules[key] == "lambda" ? 100 : 0
      priority                  = (idx + 1) * 100
    }
  }
}