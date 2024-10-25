variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "ecs_container_port" {
  type = number
}

variable "load_balancer_port" {
  type = number
}

variable "vpc_link_api_stage_name" {
  type = string
}

variable "private_vpc_name" {
  type = string
}

variable "log_retention_days" {
  type = number
}

variable "path_rules" {
  type = map(object({
    ecs_percentage_traffic    = number
    lambda_percentage_traffic = number
    paths                     = list(string)
    priority                  = number
  }))
  default = {
    weighted_paths = {
      ecs_percentage_traffic    = 10
      lambda_percentage_traffic = 90
      paths                     = ["*"]
      priority                  = 100 # Highest priority (lower number)
    }
    ecs_only_paths = {
      ecs_percentage_traffic    = 100
      lambda_percentage_traffic = 0
      paths                     = ["small-woodland-creature"]
      priority                  = 200
    }
    lambda_only_paths = {
      ecs_percentage_traffic    = 0
      lambda_percentage_traffic = 100
      paths                     = ["ice-cream-flavor"]
      priority                  = 300
    }
  }
}
