output "repo_name" {
  value = aws_ecr_repository.this.name
}

output "repo_arn" {
  value = aws_ecr_repository.this.arn
}
