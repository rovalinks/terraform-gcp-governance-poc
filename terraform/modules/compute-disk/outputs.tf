output "disk_names" {
  value = {
    for k, v in google_compute_disk.this :
    k => v.name
  }
}

output "disk_numeric_id" {
  value = {
    for k, v in google_compute_disk.this :
    k => v.disk_id
  }
}

output "disk_self_links" {
  value = {
    for k, v in google_compute_disk.this :
    k => v.self_link
  }
}