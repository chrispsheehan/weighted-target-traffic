output "lb_security_group_id" {
  value = module.load_balancer.load_balancer_security_group_id
}

output "lb_listener_arn" {
  value = module.load_balancer.lb_listener_arn
}

output "target_group_arn" {
  value = module.load_balancer.target_group_arn
}

output "api_invoke_url" {
  value = module.vpc_link.api_invoke_url
}

output "private_vpc_id" {
  value = data.aws_vpc.private.id
}

output "private_subnet_ids" {
  value = data.aws_subnets.private.ids
}
