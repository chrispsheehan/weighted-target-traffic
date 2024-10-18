resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.project_name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "logs_access_policy" {
  name   = "${local.formatted_name}_logs_access_policy"
  policy = data.aws_iam_policy_document.logs_policy.json
}

resource "aws_iam_policy" "ecr_access_policy" {
  name   = "${local.formatted_name}_ecr_access_policy"
  policy = data.aws_iam_policy_document.ecr_policy.json
}

resource "aws_iam_policy" "tg_access_policy" {
  name   = "${local.formatted_name}_tg_access_policy"
  policy = data.aws_iam_policy_document.tg_policy.json
}

resource "aws_iam_role_policy_attachment" "logs_access_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.logs_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecr_access_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "tg_access_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.tg_access_policy.arn
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = local.cloudwatch_log_name
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "task" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory

  execution_role_arn = aws_iam_role.ecs_task_role.arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = local.container_definitions
}
resource "aws_ecs_cluster" "cluster" {
  name = "${var.project_name}-cluster"
}

resource "aws_security_group" "ecs_sg" {
  vpc_id = data.aws_vpc.private.id
  name   = "${var.project_name}-ecs-sg"

  ingress {
    from_port       = 0
    to_port         = var.ecs_container_port
    protocol        = "tcp"
    security_groups = [var.lb_security_group_id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"          # Allow all protocols
    cidr_blocks      = ["0.0.0.0/0"] # Allow all IPv4 traffic
    ipv6_cidr_blocks = ["::/0"]      # Allow all IPv6 traffic
  }
}

resource "aws_ecs_service" "ecs" {
  name                  = var.project_name
  launch_type           = "FARGATE"
  cluster               = aws_ecs_cluster.cluster.id
  task_definition       = aws_ecs_task_definition.task.arn
  desired_count         = var.initial_task_count
  wait_for_steady_state = false # rm this later

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs_sg.id]
    subnets          = data.aws_subnets.private.ids
  }

  load_balancer {
    target_group_arn = var.lb_target_group_arn
    container_name   = var.project_name
    container_port   = var.ecs_container_port
  }

  # Auto-rollback and rolling deployment settings
  deployment_minimum_healthy_percent = 50  # 50% of tasks must remain healthy during deployment
  deployment_maximum_percent         = 200 # Can scale up to 200% during the deployment process

  # Health check grace period (in seconds) for the new tasks
  health_check_grace_period_seconds = 60

  force_new_deployment = false
}
