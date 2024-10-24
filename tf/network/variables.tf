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

variable "esc_percentage_traffic" {
  type    = number
  default = 10
}

variable "lambda_percentage_traffic" {
  type    = number
  default = 90
}

variable "weighted_paths" {
  type    = list(string)
  default = ["*"]
}

variable "ecs_only_paths" {
  type    = list(string)
  default = ["small-woodland-creature"]
}

variable "lambda_only_paths" {
  type    = list(string)
  default = ["ice-cream-flavor"]
}
