variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "container_port" {
  type = number
}

variable "load_balancer_port" {
  type = number
}

variable "api_stage_name" {
  type = string
}

variable "private_vpc_name" {
  type = string
}

variable "initial_task_count" {
  description = "initial and minimum number of tasks to run on the ECS instance"
  type        = number
  default     = 2

  validation {
    condition     = var.initial_task_count >= 2
    error_message = "The initial_task_count must be at least 2."
  }
}
