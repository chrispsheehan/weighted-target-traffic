variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "private_vpc_name" {
  type = string
}

variable "ecr_repo_name" {
  type = string
}

variable "vpc_link_api_stage_name" {
  type = string
}

###############################
### dynamic variables below ###
################################

variable "container_port" {
  type = number
}

variable "image_uri" {
  type = string
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

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}
