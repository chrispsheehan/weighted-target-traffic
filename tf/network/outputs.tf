output "lb_ecs_target_group_arn" {
  value = aws_lb_target_group.ecs_tg.arn
}

output "lb_lambda_target_group_arn" {
  value = aws_lb_target_group.lambda_tg.arn
}

output "ecs_lambda_listener_arn" {
  value = aws_lb_listener.ecs_lambda_listener.arn
}
