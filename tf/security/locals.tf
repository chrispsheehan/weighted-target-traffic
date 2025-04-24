locals {
  lambda_port = 65535
  private_vpc_id         = data.aws_vpc.private.id
  private_vpc_cidr_block = data.aws_vpc.private.cidr_block
  private_subnet_ids     = data.aws_subnets.private.ids
  subnet_route_table_ids = data.aws_route_tables.subnet_route_tables.ids
  private_subnet_cidrs   = [for s in data.aws_subnet.subnets : s.cidr_block]

  lb_security_group_name       = "${var.project_name}-lb-sg"
  ecs_security_group_name      = "${var.project_name}-ecs-sg"
  lambda_security_group_name   = "${var.project_name}-lambda-sg"
  vpc_link_security_group_name = "${var.project_name}-api-gateway-vpc-link-sg"
}