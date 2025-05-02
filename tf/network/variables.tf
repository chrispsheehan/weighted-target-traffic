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
  description = "Which backend to use for the default route: 'ecs' or 'lambda'"
  type        = string
  default     = "lambda"

  validation {
    condition     = var.default_weighting == "ecs" || var.default_weighting == "lambda"
    error_message = "default_weighting must be either 'ecs' or 'lambda'."
  }
}

variable "weighted_rules" {
  description = "Map of path names to their preferred backend: 'ecs' or 'lambda'"
  type        = map(string)

  default = {
    "host"                    = "ecs"
    "small-woodland-creature" = "lambda"
    "ice-cream-flavour"       = "lambda"
  }

  validation {
    condition = alltrue([
      for backend in values(var.weighted_rules) :
      backend == "ecs" || backend == "lambda"
    ])
    error_message = "Each weighted_rules value must be either 'ecs' or 'lambda'."
  }
}
