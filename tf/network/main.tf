resource "aws_lb" "lb" {
  name               = local.lb_name
  internal           = true
  load_balancer_type = "application"

  enable_deletion_protection = false

  security_groups = [data.aws_security_group.lb_sg.id]
  subnets         = data.aws_subnets.private.ids

  enable_cross_zone_load_balancing = true
}

resource "aws_lb_target_group" "ecs_tg" {
  name     = "ecs-tg"
  port     = var.ecs_container_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.private.id

  target_type = "ip"

  health_check {
    interval            = 10
    path                = local.healthcheck_path
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "ecs_lambda_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = var.load_balancer_port
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.ecs_tg.arn
        weight = local.default_ecs_percentage_traffic
      }
      target_group {
        arn    = aws_lb_target_group.lambda_tg.arn
        weight = local.default_lambda_percentage_traffic
      }
    }
  }
}

resource "aws_lb_listener_rule" "weighted_rule" {
  for_each     = local.weighted_rules_with_priority
  listener_arn = aws_lb_listener.ecs_lambda_listener.arn
  priority     = each.value.priority

  action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.ecs_tg.arn
        weight = each.value.ecs_percentage_traffic
      }
      target_group {
        arn    = aws_lb_target_group.lambda_tg.arn
        weight = each.value.lambda_percentage_traffic
      }
    }
  }

  condition {
    path_pattern {
      values = ["/${var.vpc_link_api_stage_name}/${each.key}"]
    }
  }
}

resource "aws_lb_target_group" "lambda_tg" {
  name        = "lambda-tg"
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.private.id
  target_type = "lambda"

  health_check {
    interval            = 10
    path                = local.healthcheck_path
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
