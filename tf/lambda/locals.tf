locals {
  lambda_runtime = "nodejs18.x"
  lambda_name    = "${var.function_stage}-${var.function_name}"
  lambda_bucket  = "${local.lambda_name}-bucket"
}
