package terraform

deny[msg] {

  resource := input.resource_changes[_]

  resource.type == "google_compute_instance"

  not resource.change.after.labels.environment

  msg := sprintf(
    "%s missing environment label",
    [resource.address]
  )
}

deny[msg] {

  resource := input.resource_changes[_]

  resource.type == "google_compute_instance"

  not resource.change.after.labels.owner

  msg := sprintf(
    "%s missing owner label",
    [resource.address]
  )
}

deny[msg] {

  resource := input.resource_changes[_]

  resource.type == "google_compute_instance"

  not resource.change.after.labels.application

  msg := sprintf(
    "%s missing application label",
    [resource.address]
  )
}
