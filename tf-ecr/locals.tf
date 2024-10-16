locals {
  aws_service_port = 443
  interface_endpoints = {
    ecr_api = "ecr.api"
    ecr_dkr = "ecr.dkr"
    logs    = "logs"
  }
  private_vpc_id         = data.aws_vpc.private.id
  private_vpc_cidr_block = data.aws_vpc.private.cidr_block
  private_subnet_ids     = data.aws_subnets.private.ids
  subnet_route_table_ids = data.aws_route_tables.subnet_route_tables.ids
}