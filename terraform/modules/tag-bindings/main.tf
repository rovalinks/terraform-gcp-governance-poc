# resource "google_tags_location_tag_binding" "environment" {

#   parent = var.parent

#   tag_value = var.environment_tag_value

#   location = var.location
# }

# resource "google_tags_location_tag_binding" "owner" {

#   parent = var.parent

#   tag_value = var.owner_tag_value

#   location = var.location
# }

# resource "google_tags_location_tag_binding" "application" {

#   parent = var.parent

#   tag_value = var.application_tag_value

#   location = var.location
# }


# ==========================================
# GLOBAL RESOURCES (Used when location is "global")
# ==========================================
resource "google_tags_tag_binding" "environment_global" {
  count     = lower(trimspace(var.location)) == "global" ? 1 : 0
  parent    = var.parent
  tag_value = local.environment_tag_map[lower(trimspace(var.environment))]
}

resource "google_tags_tag_binding" "owner_global" {
  count     = lower(trimspace(var.location)) == "global" ? 1 : 0
  parent    = var.parent
  tag_value = local.owner_tag_map[lower(trimspace(var.owner))]
}

resource "google_tags_tag_binding" "application_global" {
  count     = lower(trimspace(var.location)) == "global" ? 1 : 0
  parent    = var.parent
  tag_value = local.application_tag_map[lower(trimspace(var.application))]
}

# ==========================================
# REGIONAL/ZONAL RESOURCES (Used for VMs, Disks, etc.)
# ==========================================
resource "google_tags_location_tag_binding" "environment" {
  count     = lower(trimspace(var.location)) != "global" ? 1 : 0
  location  = var.location
  parent    = var.parent
  tag_value = local.environment_tag_map[lower(trimspace(var.environment))]
}

resource "google_tags_location_tag_binding" "owner" {
  count     = lower(trimspace(var.location)) != "global" ? 1 : 0
  location  = var.location
  parent    = var.parent
  tag_value = local.owner_tag_map[lower(trimspace(var.owner))]
}

resource "google_tags_location_tag_binding" "application" {
  count     = lower(trimspace(var.location)) != "global" ? 1 : 0
  location  = var.location
  parent    = var.parent
  tag_value = local.application_tag_map[lower(trimspace(var.application))]
}
