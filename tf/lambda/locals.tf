locals {
  lambda_runtime = "nodejs18.x"
  lambda_name    = "${var.vpc_link_api_stage_name}-${var.project_name}"
  lambda_bucket  = "${local.lambda_name}-bucket"
}
