variable "region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "lambda_port" {
  type = string
}

variable "private_vpc_name" {
  type = string
}

variable "vpc_link_api_stage_name" {
  type = string
}

###############################
### dynamic variables below ###
################################

variable "lambda_bucket" {
  type = string
}

variable "lambda_zip" {
  type        = string
  description = "Lambda code (zipped) to be deployed"
}

variable "lb_target_group_arn" {
  type = string
}

variable "lb_security_group_id" {
  type = string
}
