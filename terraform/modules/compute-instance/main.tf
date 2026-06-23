locals {

  mandatory_labels = {
    environment = var.environment
    owner        = var.owner
    application  = var.application
  }

}

resource "google_compute_instance" "this" {

  for_each = var.workload_ids

  name = format(
    "%s-%s-vm-%s",
    var.environment,
    var.application,
    each.value
  )

  machine_type = var.machine_type
  zone         = var.zone

  labels = var.labels

boot_disk {

  source = format(
    "%s-%s-disk-%s",
    var.environment,
    var.application,
    each.value
  )

  auto_delete = false
}

  network_interface {
    network = "default"

    access_config {}
  }
}
