variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "ecs_container_port" {
  type = number
}

variable "load_balancer_port" {
  type = number
}

variable "vpc_link_api_stage_name" {
  type = string
}

variable "private_vpc_name" {
  type = string
}

variable "log_retention_days" {
  type = number
}

variable "default_weighting" {
  description = "Weighting for the default action between ECS and Lambda"
  type = object({
    ecs_percentage_traffic    = number
    lambda_percentage_traffic = number
  })
  default = {
    ecs_percentage_traffic    = 0
    lambda_percentage_traffic = 100
  }
}

variable "weighted_rules" {
  type = map(object({
    ecs_percentage_traffic    = number
    lambda_percentage_traffic = number
    priority                  = number
  }))
  default = {
    "host" = {
      ecs_percentage_traffic    = 50
      lambda_percentage_traffic = 50
      priority                  = 300
    },
    "small-woodland-creature" = {
      ecs_percentage_traffic    = 100
      lambda_percentage_traffic = 0
      priority                  = 200
    },
    "ice-cream-flavour" = {
      ecs_percentage_traffic    = 0
      lambda_percentage_traffic = 100
      priority                  = 100
    }
  }

  validation {
    condition = length(distinct([for rule in var.weighted_rules : rule.priority])) == length(var.weighted_rules)
    error_message = "Each rule in weighted_rules must have a unique priority."
  }

  validation {
    condition = alltrue([for key in keys(var.weighted_rules) : key != "*"])
    error_message = "No path in weighted_rules can be '*'. Use var.default_weighting"
  }
}
