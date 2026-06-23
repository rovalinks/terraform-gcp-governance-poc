resource "google_compute_disk" "this" {

  for_each = var.workload_ids

  name = format(
    "%s-%s-disk-%s",
    var.environment,
    var.application,
    each.value
  )

  zone = var.zone

  type = var.type
  size = var.size_gb

  image = var.image

  labels = var.labels

  lifecycle {
    precondition {
      condition = alltrue([
        contains(keys(var.labels), "environment"),
        contains(keys(var.labels), "owner"),
        contains(keys(var.labels), "application")
      ])

      error_message = "Mandatory labels environment, owner and application are required."
    }
  }
}