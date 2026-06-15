output "snapshot_names" {
  value = {
    for k, v in google_compute_snapshot.this :
    k => v.name
  }
}

# output "disk_ids" {
#   value = {
#     for k, v in google_compute_snapshot.this :
#     k => v.snapshot_id
#   }
# }

output "snapshot_numeric_id" {
  value = {
    for k, v in google_compute_snapshot.this :
    k => v.snapshot_id
  }
}