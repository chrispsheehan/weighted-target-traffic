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

resource "aws_iam_policy" "lambda_logs_permissions" {
  name   = "${var.lambda_bucket}-lambda-logs-permissions"
  policy = data.aws_iam_policy_document.lambda_logs_permissions.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs_permissions_attach" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logs_permissions.arn
}

resource "aws_lambda_function" "this" {
  function_name = local.lambda_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = local.lambda_handler
  runtime       = local.lambda_runtime

  s3_bucket = var.lambda_bucket
  s3_key    = var.lambda_zip

  timeout = 10

  vpc_config {
    subnet_ids         = data.aws_subnets.private.ids
    security_group_ids = [data.aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      STAGE   = var.vpc_link_api_stage_name,
      BACKEND = "lambda"
    }
  }

  lifecycle {
    prevent_destroy       = false
    create_before_destroy = true # This ensures the SG isn't removed before ENIs are detached
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = var.log_retention_days
}

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = var.lb_target_group_arn
  target_id        = aws_lambda_function.this.arn

  depends_on = [aws_lambda_function.this]
}

resource "aws_lambda_permission" "this" {
  statement_id  = "${local.lambda_name}-allowELBInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = var.lb_target_group_arn
}
