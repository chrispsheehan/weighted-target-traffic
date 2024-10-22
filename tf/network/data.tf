data "aws_caller_identity" "current" {}

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

data "aws_subnet" "subnets" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

data "aws_route_tables" "subnet_route_tables" {
  filter {
    name   = "association.subnet-id"
    values = data.aws_subnets.private.ids
  }
}

data "aws_iam_policy_document" "alb_logging_policy" {
  version = "2012-10-17"
  
  statement {
    actions   = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]

    resources = ["${aws_s3_bucket.alb_logs.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["elasticloadbalancing.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:elasticloadbalancing:${var.region}:${data.aws_caller_identity.current.account_id}:loadbalancer/app/${local.lb_name}/*"]
    }
  }
}