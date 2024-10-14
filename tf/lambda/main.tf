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

resource "aws_lambda_function" "lambda" {
  depends_on = [aws_s3_object.lambda_zip]

  function_name = local.lambda_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "app.handler"
  runtime       = local.lambda_runtime

  s3_bucket = aws_s3_bucket.lambda_bucket.bucket
  s3_key    = aws_s3_object.lambda_zip.key

  environment {
    variables = {
      foo = "bar"
    }
  }
}

resource "aws_lambda_permission" "this" {
  statement_id  = "${local.lambda_name}-AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_apigatewayv2_api" "this" {
  name          = "${local.lambda_name}-APIGateway"
  protocol_type = "HTTP"
  target        = aws_lambda_function.lambda.invoke_arn
}

resource "aws_apigatewayv2_integration" "this" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "this" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.function_stage
  auto_deploy = false
}
