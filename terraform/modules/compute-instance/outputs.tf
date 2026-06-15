output "instance_name" {
  value = {
    for k, v in google_compute_instance.this :
    k => v.name
  }
}

output "instance_id" {
  value = {
    for k, v in google_compute_instance.this :
    k => v.name
  }
}