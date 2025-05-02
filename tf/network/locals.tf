locals {
  lb_name                      = "${var.project_name}-lb"
  healthcheck_path             = "/health"
  lb_security_group_name       = "${var.project_name}-lb-sg"

  # Normalize default_weighting
  default_ecs_percentage_traffic = var.default_weighting.strategy == "ecs" ? 100 : var.default_weighting.strategy == "lambda" ? 0 : var.default_weighting.ecs_percentage_traffic
  default_lambda_percentage_traffic = 100 - local.default_ecs_percentage_traffic

  # Sorted keys for deterministic priority assignment
  rule_keys = sort(keys(var.weighted_rules))

  # Normalize and add priority to each weighted rule
  weighted_rules_with_priority = {
    for idx, key in local.rule_keys : key => {
      ecs_percentage_traffic = var.weighted_rules[key].strategy == "ecs" ? 100 : var.weighted_rules[key].strategy == "lambda" ? 0 : var.weighted_rules[key].ecs_percentage_traffic
      lambda_percentage_traffic = var.weighted_rules[key].strategy == "lambda" ? 100 : var.weighted_rules[key].strategy == "ecs" ? 0 : var.weighted_rules[key].lambda_percentage_traffic
      priority = (idx + 1) * 100
    }
  }
}