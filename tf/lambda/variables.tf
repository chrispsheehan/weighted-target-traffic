variable "region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "private_vpc_name" {
  type = string
}

variable "vpc_link_api_stage_name" {
  type = string
}

variable "load_balancer_port" {
  type = number
}

###############################
### dynamic variables below ###
################################

variable "lambda_zip_path" {
  type        = string
  description = "Lambda code (zipped) to be deployed"
}

variable "load_balancer_arn" {
  type = string
}

variable "lb_security_group_id" {
  type = string
}
