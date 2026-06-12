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

module "compute_instance" {
  source = "../../modules/compute-instance"

  environment = var.environment
  owner        = var.owner
  application  = var.application

  project_id   = "project-a9c3b175-7f78-4ba6-9ad"
  region       = "europe-west2"
  zone         = "europe-west2-a"
}

module "compute_disk" {

  source = "../../modules/compute-disk"

  environment = var.environment
  owner        = var.owner
  application  = var.application

  zone = "europe-west2-a"

  size_gb = 10
  type    = "pd-standard"
}

module "compute_snapshot" {

  source = "../../modules/compute-snapshot"

  source_disk      = "${var.environment}-tagging-disk-01"

  depends_on = [
    module.compute_disk
  ]

  environment = var.environment
  owner        = var.owner
  application  = var.application
}
