variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_link_api_stage_name" {
  type = string
}

variable "container_port" {
  type = number
}

variable "private_vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "lb_security_group_id" {
  type = string
}

variable "lb_target_group_arn" {
  type = string
}

variable "initial_task_count" {
  type    = number
  default = 2
}
