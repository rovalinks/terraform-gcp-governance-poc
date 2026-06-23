resource "google_compute_snapshot" "this" {

  for_each = var.workload_ids

  name = format(
    "%s-%s-snapshot-%s",
    var.environment,
    var.application,
    each.value
  )

  source_disk = format(
    "%s-%s-disk-%s",
    var.environment,
    var.application,
    each.value
  )

  labels = var.labels
}