output "disk_name" {
  value = google_compute_disk.this.name
}

output "disk_id" {
  value = google_compute_disk.this.id
}

output "disk_self_link" {
  value = google_compute_disk.this.self_link
}
