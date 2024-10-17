variable "project_name" {
  type    = string
}

variable "region" {
  type        = string
}

variable "private_vpc_name" {
  type = string
}

###############################
### dynamic variables below ###
################################

variable "ecr_repo_name" {
  type = string
}
