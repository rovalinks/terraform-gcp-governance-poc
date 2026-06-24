locals {
  mandatory_labels = var.governance_labels
  
  admin_principal = "principal://goog/subject/${var.__ADMIN_EMAIL__}"
}