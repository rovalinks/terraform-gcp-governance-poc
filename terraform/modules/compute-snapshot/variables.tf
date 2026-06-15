variable "environment" {
  type = string
}

variable "owner" {
  type = string
}

variable "application" {
  type = string
}

variable "workload_ids" {
  type = set(string)
}