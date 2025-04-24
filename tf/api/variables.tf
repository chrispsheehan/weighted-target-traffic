variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_link_api_stage_name" {
  type = string
}

variable "log_retention_days" {
  type = number
}

variable "ecs_lambda_listener_arn" {
  type = string
}
