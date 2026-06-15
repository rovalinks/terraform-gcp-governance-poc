locals {
  mandatory_labels = {
    environment = var.environment
    owner        = var.owner
    application  = var.application
  }

  disk_name = format(
    "%s-%s-disk-01",
    var.environment,
    var.application
  )
}

resource "google_compute_disk" "this" {

  name = format(
  "%s-tagging-vm-%02d",
  var.environment,
  var.instance_number
  )

  zone = var.zone

  type    = var.type
  size    = var.size_gb

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
