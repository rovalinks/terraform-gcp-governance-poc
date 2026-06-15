output "snapshot_names" {
  value = {
    for k, v in google_compute_snapshot.this :
    k => v.name
  }
}