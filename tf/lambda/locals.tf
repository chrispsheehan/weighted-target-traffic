locals {
  lambda_runtime = "nodejs18.x"
  lambda_handler = "lambda.handler"
  lambda_name    = var.project_name
  lambda_bucket  = "${local.lambda_name}-bucket"
  lambda_security_group_name   = "${var.project_name}-lambda-sg"
}
