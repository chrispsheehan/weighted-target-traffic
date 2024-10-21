variable "region" {
  type = string
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

variable "lambda_code_bucket_name" {
  type = string
}
