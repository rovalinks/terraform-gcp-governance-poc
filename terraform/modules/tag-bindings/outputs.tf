# output "environment_binding" {
#   value = google_tags_location_tag_binding.environment.name
# }

# output "owner_binding" {
#   value = google_tags_location_tag_binding.owner.name
# }

# output "application_binding" {
#   value = google_tags_location_tag_binding.application.name
# }


output "environment_binding" {
  value = var.location == "global" ? one(google_tags_tag_binding.environment_global[*].name) : one(google_tags_location_tag_binding.environment[*].name)
}

output "owner_binding" {
  value = var.location == "global" ? one(google_tags_tag_binding.owner_global[*].name) : one(google_tags_location_tag_binding.owner[*].name)
}

output "application_binding" {
  value = var.location == "global" ? one(google_tags_tag_binding.application_global[*].name) : one(google_tags_location_tag_binding.application[*].name)
}