variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "api_stage_name" {
  type = string
}

variable "container_port" {
  type = number
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}
