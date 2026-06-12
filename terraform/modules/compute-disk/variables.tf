variable "environment" {
  type = string

  validation {
    condition     = length(trimspace(var.environment)) > 0
    error_message = "environment is mandatory."
  }
}

variable "owner" {
  type = string

  validation {
    condition     = length(trimspace(var.owner)) > 0
    error_message = "owner is mandatory."
  }
}

variable "application" {
  type = string

  validation {
    condition     = length(trimspace(var.application)) > 0
    error_message = "application is mandatory."
  }
}

variable "zone" {
  type = string
}

variable "size_gb" {
  type    = number
  default = 10

  validation {
    condition     = var.size_gb >= 10
    error_message = "Disk size must be at least 10 GB."
  }
}

variable "type" {
  type    = string
  default = "pd-standard"
}
