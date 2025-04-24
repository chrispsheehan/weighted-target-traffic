locals {
  lb_name                      = "${var.project_name}-lb"
  healthcheck_path             = "/health"
  lb_security_group_name       = "${var.project_name}-lb-sg"
}