variable "region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "stage_name" {
  type = string
}

variable "private_vpc_id" {
  type = string
}

variable "private_vpc_cidr_block" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "lb_listener_arn" {
  type        = string
  description = "arn to forward api calls to i.e. load balancer"
}
