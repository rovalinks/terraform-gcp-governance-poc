locals {
  mandatory_labels = {
    environment = var.environment
    owner       = var.owner
    application = var.application
  }
}