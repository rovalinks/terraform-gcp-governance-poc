data "google_tags_tag_key" "environment" {
  parent     = "organizations/${var.org_id}"
  short_name = "environment"
}

data "google_tags_tag_key" "owner" {
  parent     = "organizations/${var.org_id}"
  short_name = "owner"
}

data "google_tags_tag_key" "application" {
  parent     = "organizations/${var.org_id}"
  short_name = "application"
}

data "google_tags_tag_value" "environment" {
  parent     = data.google_tags_tag_key.environment.name
  short_name = var.environment
}

data "google_tags_tag_value" "owner" {
  parent     = data.google_tags_tag_key.owner.name
  short_name = var.owner
}

data "google_tags_tag_value" "application" {
  parent     = data.google_tags_tag_key.application.name
  short_name = var.application
}