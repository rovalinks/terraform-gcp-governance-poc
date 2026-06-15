output "disk_names" {
  value = {
    for k, v in google_compute_disk.this :
    k => v.name
  }
}

output "disk_id" {
  value = google_compute_disk.this.id
}

output "disk_self_link" {
  value = google_compute_disk.this.self_link
}
