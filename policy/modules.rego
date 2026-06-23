package terraform

deny[msg] {

  resource := input.resource_changes[_]

  resource.type == "google_compute_instance"

  msg := sprintf(
    "Direct resource creation not allowed: %s",
    [resource.address]
  )
}
