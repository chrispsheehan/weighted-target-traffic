private_vpc_name        = "ecs-private-vpc"
ecr_repo_name           = "weighted-ecs-target"
vpc_link_api_stage_name = "dev"
ecs_container_port      = 3000
load_balancer_port      = 80
lambda_zip_path         = "./build.zip"