locals {
  private_subnet_cidrs = [for s in data.aws_subnet.subnets : s.cidr_block]
  lb_name              = "${var.project_name}-lb"
  healthcheck_path     = "/health"
}