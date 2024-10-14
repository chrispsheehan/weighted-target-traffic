module "network" {
  source = "./network"

  project_name       = var.project_name
  region             = var.region
  api_stage_name     = var.vpc_link_api_stage_name
  private_vpc_name   = var.private_vpc_name
  load_balancer_port = var.load_balancer_port
  container_port     = var.ecs_container_port
}

module "ecs" {
  source = "./ecs"

  project_name            = var.project_name
  region                  = var.region
  vpc_link_api_stage_name = var.vpc_link_api_stage_name
  private_vpc_id          = module.network.private_vpc_id
  private_subnet_ids      = module.network.private_subnet_ids
  container_port          = var.ecs_container_port
  lb_target_group_arn     = module.network.l
  lb_security_group_id    = module.network.lb_security_group_id
}