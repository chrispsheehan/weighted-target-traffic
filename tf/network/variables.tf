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
  validation {
    condition     = var.ecs_percentage_traffic + var.lambda_percentage_traffic == 100
    error_message = "The sum of ecs_percentage_traffic and lambda_percentage_traffic must be equal to 100."
  }
}

variable "lambda_percentage_traffic" {
  type    = number
  default = 90
}
