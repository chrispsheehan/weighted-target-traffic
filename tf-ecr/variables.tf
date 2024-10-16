variable "project_name" {
  type    = string
  default = "weighted-target-traffic"
}

variable "private_vpc_name" {
  type = string
}

variable "ecr_repo_name" {
  type = string
}

variable "region" {
  type        = string
  description = "The AWS Region to use"
  default     = "eu-west-2"
}
