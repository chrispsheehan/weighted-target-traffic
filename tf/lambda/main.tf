resource "aws_security_group" "lambda_sg" {
  vpc_id = data.aws_vpc.private.id
  name   = "${var.project_name}-lambda-sg"

  ingress {
    from_port       = 0
    to_port         = var.lambda_port
    protocol        = "tcp"
    security_groups = [var.lb_security_group_id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"          # Allow all protocols
    cidr_blocks      = ["0.0.0.0/0"] # Allow all IPv4 traffic
    ipv6_cidr_blocks = ["::/0"]      # Allow all IPv6 traffic
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "${local.lambda_name}-iam"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "lambda_vpc_permissions" {
  name   = "${var.lambda_bucket}-lambda-vpc-permissions"
  policy = data.aws_iam_policy_document.lambda_vpc_permissions.json
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_permissions_attach" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_vpc_permissions.arn
}


resource "aws_lambda_function" "this" {
  function_name = local.lambda_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda.handler"
  runtime       = local.lambda_runtime

  s3_bucket = var.lambda_bucket
  s3_key    = var.lambda_zip

  vpc_config {
    subnet_ids         = data.aws_subnets.private.ids
    security_group_ids = [var.lb_security_group_id]
  }

  environment {
    variables = {
      PORT = var.lambda_port
    }
  }
}

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = var.lb_target_group_arn
  target_id        = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "this" {
  statement_id  = "${local.lambda_name}-AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
}
