variable "ecr_repo_name" {
  type = string
}

variable "region" {
  type        = string
  description = "The AWS Region to use"
  default     = "eu-west-2"
}
