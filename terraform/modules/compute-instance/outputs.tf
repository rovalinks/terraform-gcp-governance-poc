output "instance_names" {
  value = {
    for k, v in google_compute_instance.this :
    k => v.name
  }
}

output "instance_ids" {
  value = {
    for k, v in google_compute_instance.this :
    k => v.id
  }
}