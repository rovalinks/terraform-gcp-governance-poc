resource "google_tags_location_tag_binding" "environment" {

  parent = var.parent

  tag_value = var.environment_tag_value

  location = var.location
}

resource "google_tags_location_tag_binding" "owner" {

  parent = var.parent

  tag_value = var.owner_tag_value

  location = var.location
}

resource "google_tags_location_tag_binding" "application" {

  parent = var.parent

  tag_value = var.application_tag_value

  location = var.location
}
