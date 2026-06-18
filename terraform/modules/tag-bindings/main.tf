
# ==========================================
# GLOBAL RESOURCES (Used when location is "global")
# ==========================================
resource "google_tags_tag_binding" "environment_global" {
  count     = lower(trimspace(var.location)) == "global" ? 1 : 0
  parent    = var.parent
  tag_value = data.google_tags_tag_value.environment.name
}

resource "google_tags_tag_binding" "owner_global" {
  count     = lower(trimspace(var.location)) == "global" ? 1 : 0
  parent    = var.parent
  tag_value = data.google_tags_tag_value.owner.name
}

resource "google_tags_tag_binding" "application_global" {
  count     = lower(trimspace(var.location)) == "global" ? 1 : 0
  parent    = var.parent
  tag_value = data.google_tags_tag_value.application.name
}

# ==========================================
# REGIONAL/ZONAL RESOURCES (Used for VMs, Disks, etc.)
# ==========================================
resource "google_tags_location_tag_binding" "environment" {
  count     = lower(trimspace(var.location)) != "global" ? 1 : 0
  location  = var.location
  parent    = var.parent
  tag_value = data.google_tags_tag_value.environment.name
}

resource "google_tags_location_tag_binding" "owner" {
  count     = lower(trimspace(var.location)) != "global" ? 1 : 0
  location  = var.location
  parent    = var.parent
  tag_value = data.google_tags_tag_value.owner.name
}

resource "google_tags_location_tag_binding" "application" {
  count     = lower(trimspace(var.location)) != "global" ? 1 : 0
  location  = var.location
  parent    = var.parent
  tag_value = data.google_tags_tag_value.application.name
}
