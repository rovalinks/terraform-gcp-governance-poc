locals {
  mandatory_labels = {
    environment = var.environment
    owner        = var.owner
    application  = var.application
  }
  admin_principal = "principal://goog/subject/${var.admin_email}"
}