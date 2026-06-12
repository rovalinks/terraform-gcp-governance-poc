variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition = contains(
      ["dev", "test", "uat", "prod"],
      lower(var.environment)
    )

    error_message = "Environment must be one of: dev, test, uat, prod."
  }
}

variable "owner" {
  description = "Resource owner"
  type        = string

  validation {
    condition     = length(trimspace(var.owner)) > 0
    error_message = "Owner is mandatory."
  }
}

variable "application" {
  description = "Application name"
  type        = string

  validation {
    condition     = length(trimspace(var.application)) > 0
    error_message = "Application is mandatory."
  }
}
