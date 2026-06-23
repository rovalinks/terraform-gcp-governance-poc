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

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "machine_type" {
  type    = string
  default = "e2-micro"
}

variable "image" {
  type    = string
  default = "debian-cloud/debian-12"
}

variable "workload_ids" {
  type = set(string)
}

variable "labels" {
  type    = map(string)
  default = {}
}