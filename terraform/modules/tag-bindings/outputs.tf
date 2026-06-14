output "environment_binding" {
  value = google_tags_location_tag_binding.environment.name
}

output "owner_binding" {
  value = google_tags_location_tag_binding.owner.name
}

output "application_binding" {
  value = google_tags_location_tag_binding.application.name
}
