data "aws_route_tables" "subnet_route_tables" {
  filter {
    name   = "association.subnet-id"
    values = var.private_subnet_ids
  }
}
