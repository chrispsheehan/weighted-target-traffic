output "lb_security_group_id" {
  value = aws_security_group.lb_sg.id
}

output "lb_ecs_target_group_arn" {
  value = aws_lb_target_group.ecs_tg.arn
}

output "lb_lambda_target_group_arn" {
  value = aws_lb_target_group.lambda_tg.arn
}

output "api_invoke_url" {
  value = aws_apigatewayv2_stage.this.invoke_url
}
