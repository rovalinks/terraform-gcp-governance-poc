locals {
  mandatory_labels = {
    environment = var.environment
    owner        = var.owner
    application  = var.application
  }
}

resource "google_compute_disk" "this" {

  for_each = var.workload_ids

  name = format(
    "%s-%s-disk-%s",
    var.environment,
    var.application,
    each.value
  )

  zone = var.zone

  type = var.type
  size = var.size_gb

  image = var.image

  labels = local.mandatory_labels

  lifecycle {
    precondition {
      condition = alltrue([
        contains(keys(local.mandatory_labels), "environment"),
        contains(keys(local.mandatory_labels), "owner"),
        contains(keys(local.mandatory_labels), "application")
      ])

      error_message = "Mandatory labels environment, owner and application are required."
    }
  }
}