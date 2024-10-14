module "load_balancer" {
  source = "./load_balancer"

  project_name           = var.project_name
  container_port         = var.container_port
  load_balancer_port     = var.load_balancer_port
  private_vpc_id         = data.aws_vpc.private.id
  private_vpc_cidr_block = data.aws_vpc.private.cidr_block
  private_subnet_ids     = data.aws_subnets.private.ids
  private_subnet_cidrs   = local.private_subnet_cidrs
}

module "vpc_link" {
  source = "./vpc_link"

  project_name           = var.project_name
  region                 = var.region
  stage_name             = var.api_stage_name
  lb_listener_arn        = module.load_balancer.lb_listener_arn
  private_vpc_id         = data.aws_vpc.private.id
  private_vpc_cidr_block = data.aws_vpc.private.cidr_block
  private_subnet_ids     = data.aws_subnets.private.ids
  private_subnet_cidrs   = local.private_subnet_cidrs
}
