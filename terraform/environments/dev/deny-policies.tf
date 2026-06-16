# Look up the current GCP project context dynamically from the active provider configuration
data "google_project" "current" {}

# Local block to dynamic-load and parse your centralized YAML file
locals {
  # FIX: path.module targets terraform/environments/dev/
  # Walking up 3 levels brings us out to the repository root where iam-deny/ sits
  deny_config_path = "${path.module}/../../../iam-deny/deny-tagbinding-governance.yaml"
  deny_config      = yamldecode(file(local.deny_config_path))
}

# Native IAM Deny Policy deployment for Tag and Instance Governance
resource "google_iam_deny_policy" "deny_tagbinding_governance" {
  provider = google-beta
  
  # FIX: Dynamically interpolates the Project Number from the data source and wraps it inside urlencode()
  parent = urlencode("cloudresourcemanager.googleapis.com/projects/${data.google_project.current.number}")
  
  name         = "deny-tagbinding-governance"
  display_name = "Guardrail: Prevent Tag Removal (From YAML File)"

  # Dynamically pull the rules loop straight out of your parsed YAML file
  dynamic "rules" {
    for_each = local.deny_config.rules
    content {
      description = lookup(rules.value, "description", "Managed by YAML policy file")

      deny_rule {
        denied_principals    = rules.value.denyRule.deniedPrincipals
        exception_principals = lookup(rules.value.denyRule, "exceptionPrincipals", [])
        denied_permissions   = rules.value.denyRule.deniedPermissions
        
        dynamic "denial_condition" {
          for_each = lookup(rules.value.denyRule, "denialCondition", null) != null ? [rules.value.denyRule.denialCondition] : []
          content {
            title       = denial_condition.value.title
            description = lookup(denial_condition.value, "description", null)
            expression  = denial_condition.value.expression
          }
        }
      }
    }
  }
}
