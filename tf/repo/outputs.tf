output "ecr_repo_name" {
  value = aws_ecr_repository.this.name
}

output "lambda_code_bucket" {
  value = aws_s3_bucket.lambda_bucket.bucket
}
