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

variable "ecs_container_port" {
  type = number
}


###############################
### dynamic variables below ###
################################

variable "ecs_image_uri" {
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

variable "log_retention_days" {
  type = number
}