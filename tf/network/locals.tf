locals {
  lb_name                      = "${var.project_name}-lb"
  healthcheck_path             = "/health"
  lb_security_group_name       = "${var.project_name}-lb-sg"

  weighted_rules_with_priority = {
    for idx, key in tolist(keys(var.weighted_rules)) :
    key => merge(var.weighted_rules[key], {
      priority = (idx + 1) * 100
    })
  }
}