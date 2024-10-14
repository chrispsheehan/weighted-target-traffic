variable "project_name" {
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

variable "container_port" {
  type = number
}

variable "load_balancer_port" {
  type = number
}
