locals {
  mandatory_labels = {
    environment = var.environment
    owner       = var.owner
    application = var.application
  }

  instance_name = format(
    "%s-%s-vm-01",
    var.environment,
    var.application
  )
}

resource "google_compute_instance" "this" {

  name = format(
  "%s-tagging-vm-%02d",
  var.environment,
  var.instance_number
 )

  machine_type = var.machine_type
  zone         = var.zone

  labels = local.mandatory_labels

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = "default"

    access_config {}
  }
}
