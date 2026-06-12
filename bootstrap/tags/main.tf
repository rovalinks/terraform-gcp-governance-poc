resource "google_tags_tag_key" "environment" {
  parent     = "organizations/${var.org_id}"
  short_name = "environment"
}

resource "google_tags_tag_key" "owner" {
  parent     = "organizations/${var.org_id}"
  short_name = "owner"
}

resource "google_tags_tag_key" "application" {
  parent     = "organizations/${var.org_id}"
  short_name = "application"
}

##################################################
# Environment Tag Values
##################################################

resource "google_tags_tag_value" "dev" {
  parent     = google_tags_tag_key.environment.id
  short_name = "dev"
}

resource "google_tags_tag_value" "test" {
  parent     = google_tags_tag_key.environment.id
  short_name = "test"
}

resource "google_tags_tag_value" "uat" {
  parent     = google_tags_tag_key.environment.id
  short_name = "uat"
}

resource "google_tags_tag_value" "prod" {
  parent     = google_tags_tag_key.environment.id
  short_name = "prod"
}

##################################################
# Owner Tag Values
##################################################

resource "google_tags_tag_value" "platform_team" {
  parent     = google_tags_tag_key.owner.id
  short_name = "platform-team"
}

resource "google_tags_tag_value" "cloud_team" {
  parent     = google_tags_tag_key.owner.id
  short_name = "cloud-team"
}

resource "google_tags_tag_value" "security_team" {
  parent     = google_tags_tag_key.owner.id
  short_name = "security-team"
}

resource "google_tags_tag_value" "networking_team" {
  parent     = google_tags_tag_key.owner.id
  short_name = "networking-team"
}

##################################################
# Application Tag Values
##################################################

resource "google_tags_tag_value" "payments" {
  parent     = google_tags_tag_key.application.id
  short_name = "payments"
}

resource "google_tags_tag_value" "ecommerce" {
  parent     = google_tags_tag_key.application.id
  short_name = "ecommerce"
}

resource "google_tags_tag_value" "crm" {
  parent     = google_tags_tag_key.application.id
  short_name = "crm"
}

resource "google_tags_tag_value" "analytics" {
  parent     = google_tags_tag_key.application.id
  short_name = "analytics"
}
