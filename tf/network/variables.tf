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

variable "weighted_rules" {
  type = map(object({
    ecs_percentage_traffic    = number
    lambda_percentage_traffic = number
    priority                  = number
  }))
  default = {
    "*" = {
      ecs_percentage_traffic    = 10
      lambda_percentage_traffic = 90
      priority                  = 900
    },
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
    condition = alltrue([for rule in var.weighted_rules : rule.priority <= var.weighted_rules["*"].priority])
    error_message = "The '*' rule must have the highest priority number in weighted_rules."
  }

  validation {
    condition = length(distinct([for rule in var.weighted_rules : rule.priority])) == length(var.weighted_rules)
    error_message = "Each rule in weighted_rules must have a unique priority."
  }
}
