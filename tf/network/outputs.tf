output "lb_security_group_id" {
  value = aws_security_group.lb_sg.id
}

output "lb_ecs_listener_arn" {
  value = aws_lb_listener.ecs_listener.arn
}

output "api_invoke_url" {
  value = module.vpc_link.api_invoke_url
}
