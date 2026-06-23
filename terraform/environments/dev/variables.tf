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

variable "workload_ids" {
  description = "List of workload identifiers"
  type        = set(string)

  validation {
    condition = alltrue([
      for id in var.workload_ids :
      can(regex("^\\d{2}$", id))
    ])

    error_message = "Workload IDs must be two digits (01, 02, 03)."
  }
}

variable "org_id" {
  type = string
}

variable "project_id" {
  type = string
}

variable "project_number" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "__ADMIN_EMAIL__" {
  type = string
}

variable "governance_labels" {
  description = "Mandatory governance labels"
  type        = map(string)
}