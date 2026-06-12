##################################################
# Tag Keys
##################################################

output "environment_tag_key" {
  value = google_tags_tag_key.environment.id
}

output "owner_tag_key" {
  value = google_tags_tag_key.owner.id
}

output "application_tag_key" {
  value = google_tags_tag_key.application.id
}

##################################################
# Environment Tag Values
##################################################

output "environment_dev" {
  value = google_tags_tag_value.dev.id
}

output "environment_test" {
  value = google_tags_tag_value.test.id
}

output "environment_uat" {
  value = google_tags_tag_value.uat.id
}

output "environment_prod" {
  value = google_tags_tag_value.prod.id
}

##################################################
# Owner Tag Values
##################################################

output "owner_platform_team" {
  value = google_tags_tag_value.platform_team.id
}

output "owner_cloud_team" {
  value = google_tags_tag_value.cloud_team.id
}

output "owner_security_team" {
  value = google_tags_tag_value.security_team.id
}

output "owner_networking_team" {
  value = google_tags_tag_value.networking_team.id
}

##################################################
# Application Tag Values
##################################################

output "application_payments" {
  value = google_tags_tag_value.payments.id
}

output "application_ecommerce" {
  value = google_tags_tag_value.ecommerce.id
}

output "application_crm" {
  value = google_tags_tag_value.crm.id
}

output "application_analytics" {
  value = google_tags_tag_value.analytics.id
}
