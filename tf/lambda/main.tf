resource "aws_security_group" "ecs_sg" {
  vpc_id = data.aws_vpc.private.id
  name   = "${var.project_name}-ecs-sg"

  ingress {
    from_port       = 0
    to_port         = 0
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

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = local.lambda_bucket
}

resource "aws_s3_object" "lambda_zip" {
  bucket        = aws_s3_bucket.lambda_bucket.id
  key           = basename(var.lambda_zip_path)
  source        = var.lambda_zip_path
  force_destroy = true
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "${local.lambda_name}-iam"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_function" "this" {
  depends_on = [aws_s3_object.lambda_zip]

  function_name = local.lambda_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda.handler"
  runtime       = local.lambda_runtime

  s3_bucket = aws_s3_bucket.lambda_bucket.bucket
  s3_key    = aws_s3_object.lambda_zip.key

  vpc_config {
    subnet_ids         = data.aws_subnets.private.ids
    security_group_ids = [var.lb_security_group_id]
  }

  environment {
    variables = {
      foo = "bar"
    }
  }
}

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = var.load_balancer_arn
  target_id        = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "this" {
  statement_id  = "${local.lambda_name}-AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
}
