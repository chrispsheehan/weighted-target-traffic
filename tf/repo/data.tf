data "aws_vpc" "private" {
  filter {
    name   = "tag:Name"
    values = [var.private_vpc_name]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.private.id]
  }
}

data "aws_route_tables" "subnet_route_tables" {
  filter {
    name   = "association.subnet-id"
    values = data.aws_subnets.private.ids
  }
}
