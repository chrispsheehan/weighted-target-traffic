resource "aws_security_group" "vpc_endpoint" {
  name        = "${var.project_name}-vpc-endpoint-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = local.private_vpc_id

  ingress {
    from_port   = local.aws_service_port
    to_port     = local.aws_service_port
    protocol    = "tcp"
    cidr_blocks = [local.private_vpc_cidr_block]
  }

  egress {
    from_port   = local.aws_service_port
    to_port     = local.aws_service_port
    protocol    = "tcp"
    cidr_blocks = [local.private_vpc_cidr_block]
  }
}

resource "aws_vpc_endpoint" "interface_endpoints" {
  for_each            = local.interface_endpoints
  vpc_id              = local.private_vpc_id
  service_name        = "com.amazonaws.${var.region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  subnet_ids          = local.private_subnet_ids
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "gateway_s3" {
  vpc_id            = local.private_vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = local.subnet_route_table_ids
}

resource "aws_ecr_repository" "this" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"

  force_delete = true

  image_scanning_configuration {
    scan_on_push = false
  }
}