locals {
  private_subnet_cidrs = [for s in data.aws_subnet.subnets : s.cidr_block]
}