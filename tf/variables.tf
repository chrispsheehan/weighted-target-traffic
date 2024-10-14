variable "project_name" {
  type    = string
  default = "weighted-target-traffic"
}

variable "region" {
  type        = string
  description = "The AWS Region to use"
  default     = "eu-west-2"
}

variable "private_vpc_name" {
  type = string
}

variable "vpc_link_api_stage_name" {
  type = string
}

variable "ecs_container_port" {
  type = number
}

variable "load_balancer_port" {
  type = number
}

variable "lambda_zip_path" {
  type        = string
  description = "Lambda code (zipped) to be deployed"
}
