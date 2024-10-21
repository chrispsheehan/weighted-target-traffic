project_name            = "weighted-target-traffic"
private_vpc_name        = "ecs-private-vpc"
region                  = "eu-west-2"
vpc_link_api_stage_name = "dev"
ecs_container_port      = 3000
lambda_port             = 4000
load_balancer_port      = 80
lambda_zip_path         = "./build.zip"