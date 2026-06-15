terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = "project-a9c3b175-7f78-4ba6-9ad"
  region  = "europe-west2"
  zone    = "europe-west2-a"
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

module "compute_disk" {

  source = "../../modules/compute-disk"

  environment = var.environment
  owner        = var.owner
  application  = var.application
  workload_ids = var.workload_ids

  zone    = "europe-west2-a"
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

  project_id = "project-a9c3b175-7f78-4ba6-9ad"
  region     = "europe-west2"
  zone       = "europe-west2-a"
}


module "vm_tag_bindings" {

  source = "../../modules/tag-bindings"

  for_each = module.compute_instance.instance_numeric_id

  depends_on = [
    module.compute_instance
  ]

  parent = format(
    "//compute.googleapis.com/projects/%s/zones/%s/instances/%s",
    "106228803995",
    "europe-west2-a",
    each.value
  )

  #location = "europe-west2-a"

  environment_tag_value = local.environment_tag_map[var.environment]

  owner_tag_value = local.owner_tag_map[var.owner]

  application_tag_value = local.application_tag_map[var.application]
}

module "disk_tag_bindings" {

  source = "../../modules/tag-bindings"

  for_each = module.compute_disk.disk_numeric_id

  depends_on = [
    module.compute_disk
  ]

  parent = format(
    "//compute.googleapis.com/projects/%s/zones/%s/disks/%s",
    "106228803995",
    "europe-west2-a",
    each.value
  )

#  location = "europe-west2-a"

  environment_tag_value = local.environment_tag_map[var.environment]

  owner_tag_value       = local.owner_tag_map[var.owner]

  application_tag_value = local.application_tag_map[var.application]
}


module "snapshot_tag_bindings" {

  source = "../../modules/tag-bindings"

  for_each = module.compute_snapshot.snapshot_numeric_id

  depends_on = [
    module.compute_snapshot
  ]

  parent = format(
    "//compute.googleapis.com/projects/%s/global/snapshots/%s",
    "106228803995",
    each.value
  )

  #location = "europe-west2-a"

  environment_tag_value = local.environment_tag_map[var.environment]

  owner_tag_value       = local.owner_tag_map[var.owner]

  application_tag_value = local.application_tag_map[var.application]
}

# module "snapshot_tag_bindings" {

#   source = "../../modules/tag-bindings"

#   for_each = module.compute_snapshot.snapshot_numeric_id

#   parent = format(
#     "//compute.googleapis.com/projects/%s/global/snapshots/%s",
#     "106228803995",
#     each.value
#   )

#   location = "global"

#   environment_tag_value = local.environment_tag_map[var.environment]

#   owner_tag_value       = local.owner_tag_map[var.owner]

#   application_tag_value = local.application_tag_map[var.application]
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