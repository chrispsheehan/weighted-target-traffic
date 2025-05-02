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

variable "default_weighting" {
  description = "Which backend to use for the default route (ecs, lambda, or split strategy)"
  type = object({
    strategy                  = string
    ecs_percentage_traffic    = optional(number)
    lambda_percentage_traffic = optional(number)
  })

  default = {
    strategy = "lambda"
  }

  validation {
    condition = (
      contains(["ecs", "lambda", "split"], var.default_weighting.strategy) &&
      (
        var.default_weighting.strategy != "split" ||
        try(var.default_weighting.ecs_percentage_traffic + var.default_weighting.lambda_percentage_traffic, -1) == 100
      )
    )
    error_message = "Strategy must be 'ecs', 'lambda', or 'split'. If 'split', ecs + lambda must equal 100."
  }
}

variable "weighted_rules" {
  description = "Per-endpoint routing rules (ecs, lambda, or split strategy)"
  type = map(object({
    strategy                  = string
    ecs_percentage_traffic    = optional(number)
    lambda_percentage_traffic = optional(number)
  }))

  default = {
    "ice-cream-flavour" = {
      strategy = "lambda"
    },
    "small-woodland-creature" = {
      strategy = "ecs"
    },
    "host" = {
      strategy = "split"
      ecs_percentage_traffic = 50
      lambda_percentage_traffic = 50
    }
  }

  validation {
    condition = alltrue([
      for rule in values(var.weighted_rules) :
      contains(["ecs", "lambda", "split"], rule.strategy) &&
      (
        rule.strategy != "split" ||
        try(rule.ecs_percentage_traffic + rule.lambda_percentage_traffic, -1) == 100
      )
    ])
    error_message = "Each rule must have strategy 'ecs', 'lambda', or 'split'. If 'split', percentages must sum to 100."
  }
}
