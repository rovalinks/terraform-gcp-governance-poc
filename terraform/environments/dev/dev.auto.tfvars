project_id     = "project-a9c3b175-7f78-4ba6-9ad"
project_number = "106228803995"

region = "europe-west2"
zone   = "europe-west2-a"

environment = "dev"
owner       = "platform-team"
application = "payments"
workload_ids = [
  "01", "02"
]

  
// Later If i want to include more workloads, I can add them to the workload_ids list like this:
// workload_ids = [01, 02, 03]
