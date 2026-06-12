locals {
  mandatory_labels = {
    environment = var.environment
    owner        = var.owner
    application  = var.application
  }
}

resource "google_compute_snapshot" "this" {

  name = "${var.environment}-tagging-snapshot-01"

  source_disk = var.source_disk

  labels = local.mandatory_labels
}
