# Look up current project dynamically
data "google_project" "current" {}

locals {

  # Discover all generated deny policy YAML files
  deny_policy_files = fileset(
    "${path.module}/../../../iam-deny/generated",
    "*.yaml"
  )

  # Load and parse all YAML files
  deny_policies = {
    for file in local.deny_policy_files :
    replace(file, ".yaml", "") => yamldecode(
      file("${path.module}/../../../iam-deny/generated/${file}")
    )
  }
}

resource "google_iam_deny_policy" "deny_policies" {

  for_each = local.deny_policies

  provider = google-beta

  parent = urlencode(
    "cloudresourcemanager.googleapis.com/projects/${data.google_project.current.number}"
  )

  name         = each.key
  display_name = each.key

  dynamic "rules" {

    for_each = each.value.rules

    content {

      description = lookup(
        rules.value,
        "description",
        "Managed by Terraform from YAML"
      )

      deny_rule {

        denied_principals = rules.value.denyRule.deniedPrincipals

        exception_principals = lookup(
          rules.value.denyRule,
          "exceptionPrincipals",
          []
        )

        denied_permissions = rules.value.denyRule.deniedPermissions

        dynamic "denial_condition" {

          for_each = lookup(
            rules.value.denyRule,
            "denialCondition",
            null
          ) != null ? [rules.value.denyRule.denialCondition] : []

          content {
            title       = denial_condition.value.title
            description = lookup(
              denial_condition.value,
              "description",
              null
            )
            expression = denial_condition.value.expression
          }
        }
      }
    }
  }
}