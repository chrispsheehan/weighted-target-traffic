output "load_balancer_security_group_id" {
  value = aws_security_group.lb_sg.id
}

output "lb_listener_arn" {
  value = aws_lb_listener.listener.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.tg.arn
}
