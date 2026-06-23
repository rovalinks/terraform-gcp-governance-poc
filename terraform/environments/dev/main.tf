terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}


resource "google_compute_instance" "legacy-vm" {
  name         = "legacy-vm"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}

/*
resource "google_compute_instance" "legacy-vm" {

  name         = "legacy-vm"
  machine_type = "e2-medium"

  labels = {
    environment = var.environment
    owner        = var.owner
    application  = var.application
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}

module "legacy_vm_tag_bindings" {

  source = "../../modules/tag-bindings"

  depends_on = [
    google_compute_instance.legacy-vm
  ]

  parent = format(
    "//compute.googleapis.com/projects/%s/zones/%s/instances/%s",
    var.project_number,
    var.zone,
    google_compute_instance.legacy-vm.instance_id
  )

  location = var.zone,

  environment = var.environment
  owner        = var.owner
  application  = var.application
}
*/

module "compute_disk" {

  source = "../../modules/compute-disk"

  environment = var.environment
  owner        = var.owner
  application  = var.application
  workload_ids = var.workload_ids

  zone = var.zone
  size_gb = 10
  type    = "pd-standard"

  image = "debian-cloud/debian-12"
}


module "compute_instance" {

  depends_on = [
    module.compute_disk
  ]

  source = "../../modules/compute-instance"

  environment = var.environment
  owner        = var.owner
  application  = var.application

  workload_ids = var.workload_ids

  labels = local.mandatory_labels

  project_id = var.project_id
  region     = var.region
  zone       = var.zone
}


# module "vm_tag_bindings" {

#   source = "../../modules/tag-bindings"

#   for_each = module.compute_instance.instance_numeric_id

#   depends_on = [
#     module.compute_instance
#   ]

#   parent = format(
#     "//compute.googleapis.com/projects/%s/zones/%s/instances/%s",
#     var.project_number,
#     var.zone,
#     each.value
#   )

#   org_id = var.org_id
  
#   location = var.zone

#   environment = var.environment

#   owner = var.owner

#   application = var.application
# }

# module "disk_tag_bindings" {

#   source = "../../modules/tag-bindings"

#   for_each = module.compute_disk.disk_numeric_id

#   depends_on = [
#     module.compute_disk
#   ]

#   parent = format(
#     "//compute.googleapis.com/projects/%s/zones/%s/disks/%s",
#     var.project_number,
#     var.zone,
#     each.value
#   )

#   org_id = var.org_id
  
#   location = var.zone

#   environment = var.environment

#   owner = var.owner

#   application = var.application
# }


# module "snapshot_tag_bindings" {

#   source = "../../modules/tag-bindings"

#   for_each = module.compute_snapshot.snapshot_numeric_id

#   depends_on = [
#     module.compute_snapshot
#   ]

#   parent = format(
#     "//compute.googleapis.com/projects/%s/global/snapshots/%s",
#     var.project_number,
#     each.value
#   )

#   org_id = var.org_id

#   location = "global"

#   environment = var.environment

#   owner    = var.owner

#   application = var.application
# }

# module "snapshot_tag_bindings" {

#   source = "../../modules/tag-bindings"

#   for_each = module.compute_snapshot.snapshot_numeric_id

#   parent = format(
#     "//compute.googleapis.com/projects/%s/global/snapshots/%s",
#     var.project_number,
#     each.value
#   )

#   location = "global"

#   environment = var.environment

#   owner_tag_value       = var.owner

#   application_tag_value = var.application
# }

module "compute_snapshot" {

  source = "../../modules/compute-snapshot"

  depends_on = [
    module.compute_instance
  ]

  environment = var.environment
  owner        = var.owner
  application  = var.application
  workload_ids = var.workload_ids
}


/*
resource "google_bigquery_dataset" "governance_inventory1" {
  dataset_id = "governance_inventory1"
  location   = "europe-west2"

  }
*/
resource "google_bigquery_dataset" "governance_inventory1" {
  dataset_id = "governance_inventory1"
  location = var.region

  labels = {
    environment = var.environment
    owner        = var.owner
    application  = var.application
  }
}

resource "google_bigquery_dataset" "governance_inventory2" {
  dataset_id = "governance_inventory2"
  location = var.region
}
