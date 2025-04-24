data "aws_caller_identity" "current" {}


data "aws_security_group" "vpc_link" {
  name = local.vpc_link_security_group_name
}
