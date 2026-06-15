# Governance PoC - Required Permissions and Roles

## Overview

This document summarises all permissions and IAM roles required to implement and operate the governance Proof of Concept.

The permissions are grouped by implementation layer and identify whether they are required during setup, ongoing operations, or remediation activities.

---

# Permission Model

The PoC used three categories of permissions:

1. Governance Administrator
2. Terraform Deployment User
3. Operations and Remediation User

---

# Layer 1 - Preventative Controls

## Terraform Deployment

Required for users deploying infrastructure through Terraform.

### Minimum Project Roles

| Role                           | Purpose                             |
| ------------------------------ | ----------------------------------- |
| roles/compute.admin            | Create and manage Compute resources |
| roles/iam.serviceAccountUser   | Attach service accounts to VMs      |
| roles/compute.instanceAdmin.v1 | Manage VM lifecycle                 |
| roles/viewer                   | Read project metadata               |

---

## Terraform Validation

No additional GCP permissions required.

Validation occurs locally during Terraform execution.

Example:

```text
terraform plan
terraform apply
```

---

## Mandatory Labels

No additional GCP permissions required.

Labels are automatically injected by Terraform.

Example:

```hcl
labels = {
  environment = var.environment
  owner        = var.owner
  application  = var.application
}
```

---

## Resource Manager Tags

Required only if Resource Manager Tags are implemented.

### Organisation-Level Roles

| Role                           | Purpose                        |
| ------------------------------ | ------------------------------ |
| roles/resourcemanager.tagAdmin | Create Tag Keys and Tag Values |
| roles/resourcemanager.tagUser  | Bind tags to resources         |

---

## Custom Organization Policies

Required to create custom constraints.

### Organisation Roles

| Role                         | Purpose                      |
| ---------------------------- | ---------------------------- |
| roles/orgpolicy.policyAdmin  | Manage Organization Policies |
| roles/orgpolicy.policyViewer | View policies                |

---

### Permissions Used

```text
orgpolicy.customConstraints.create
orgpolicy.customConstraints.update
orgpolicy.customConstraints.get
orgpolicy.policies.update
orgpolicy.policies.get
```

---

## IAM Deny Policies

Required to implement preventative deny controls.

### Organisation Roles

| Role                    | Purpose                                     |
| ----------------------- | ------------------------------------------- |
| roles/iam.denyAdmin     | Create and manage Deny Policies             |
| roles/iam.securityAdmin | Alternative broader IAM administration role |

---

### Permissions Used

```text
iam.denypolicies.create
iam.denypolicies.update
iam.denypolicies.delete
iam.denypolicies.get
iam.denypolicies.list
```

---

# Layer 2 - Brownfield Detection

Layer 2 exports Cloud Asset Inventory metadata into BigQuery.

---

## Cloud Asset Export

Required for the user initiating exports.

### Project Roles

| Role                                    | Purpose                      |
| --------------------------------------- | ---------------------------- |
| roles/cloudasset.viewer                 | Export Cloud Asset Inventory |
| roles/serviceusage.serviceUsageConsumer | Consume Cloud Asset API      |

---

### Permissions Used

```text
cloudasset.assets.exportResource
cloudasset.assets.searchAllResources
serviceusage.services.use
```

---

## BigQuery Dataset Creation

Required during initial setup.

### Project Roles

| Role                 | Purpose                    |
| -------------------- | -------------------------- |
| roles/bigquery.admin | Create datasets and tables |

---

### Permissions Used

```text
bigquery.datasets.create
bigquery.tables.create
bigquery.tables.update
```

---

## BigQuery Query Execution

Required for brownfield detection.

### Project Roles

| Role                      | Purpose            |
| ------------------------- | ------------------ |
| roles/bigquery.user       | Run queries        |
| roles/bigquery.dataViewer | Read exported data |

---

### Permissions Used

```text
bigquery.jobs.create
bigquery.tables.getData
bigquery.tables.get
```

---

## Cloud Asset Service Agent

Cloud Asset Inventory uses a Google-managed service account.

Service Identity:

```text
service-106228803995@gcp-sa-cloudasset.iam.gserviceaccount.com
```

Required Roles:

| Role                          | Scope   | Purpose                         |
| ----------------------------- | ------- | ------------------------------- |
| roles/cloudasset.serviceAgent | Project | Default Cloud Asset permissions |
| roles/bigquery.jobUser        | Project | Submit BigQuery jobs            |

---

# Layer 3 - Remediation

Layer 3 demonstrates updating non-compliant resources.

---

## Compute Engine Remediation

Required for Operations teams.

### Project Roles

| Role                           | Purpose                  |
| ------------------------------ | ------------------------ |
| roles/compute.instanceAdmin.v1 | Update VM labels         |
| roles/compute.storageAdmin     | Update disk labels       |
| roles/compute.admin            | Alternative broader role |

---

### Permissions Used

VM Labels:

```text
compute.instances.setLabels
compute.instances.get
```

Disk Labels:

```text
compute.disks.setLabels
compute.disks.get
```

Snapshot Labels:

```text
compute.snapshots.setLabels
compute.snapshots.get
```

---

## Revalidation

Uses the same Layer 2 permissions.

Required Roles:

| Role                      |
| ------------------------- |
| roles/cloudasset.viewer   |
| roles/bigquery.user       |
| roles/bigquery.dataViewer |

---

# API Requirements

The following APIs were enabled.

| API                  | Required For          |
| -------------------- | --------------------- |
| Compute Engine API   | Compute resources     |
| Cloud Asset API      | Asset exports         |
| BigQuery API         | Brownfield detection  |
| Resource Manager API | Tags and Org Policies |
| IAM API              | Deny Policies         |

---

## Enable APIs

```bash
gcloud services enable \
    compute.googleapis.com \
    cloudasset.googleapis.com \
    bigquery.googleapis.com \
    cloudresourcemanager.googleapis.com \
    iam.googleapis.com
```

---

# Recommended Enterprise Role Separation

## Governance Team

Organisation Scope

Roles:

```text
roles/orgpolicy.policyAdmin
roles/iam.denyAdmin
roles/resourcemanager.tagAdmin
```

Responsibilities:

* Define governance standards.
* Manage policies.
* Manage deny controls.
* Manage Resource Manager Tags.

---

## Platform Engineering Team

Project Scope

Roles:

```text
roles/compute.admin
roles/iam.serviceAccountUser
roles/bigquery.admin
roles/cloudasset.viewer
```

Responsibilities:

* Deploy infrastructure.
* Execute exports.
* Operate governance tooling.

---

## Operations Team

Project Scope

Roles:

```text
roles/compute.instanceAdmin.v1
roles/compute.storageAdmin
roles/bigquery.user
roles/bigquery.dataViewer
```

Responsibilities:

* Investigate findings.
* Remediate resources.
* Validate compliance.

---

# Least Privilege Recommendations

The PoC was executed using elevated permissions for simplicity.

For production implementations:

* Separate duties between Governance, Platform, and Operations teams.
* Prefer predefined roles over Owner permissions.
* Grant Organisation roles only to governance administrators.
* Restrict remediation permissions to operational teams.
* Periodically review access assignments.

---

# Summary

| Layer   | Capability            | Minimum Roles                       |
| ------- | --------------------- | ----------------------------------- |
| Layer 1 | Terraform deployment  | Compute Admin, Service Account User |
| Layer 1 | Org Policies          | Org Policy Admin                    |
| Layer 1 | IAM Deny              | IAM Deny Admin                      |
| Layer 1 | Resource Manager Tags | Tag Admin, Tag User                 |
| Layer 2 | Asset Export          | Cloud Asset Viewer                  |
| Layer 2 | BigQuery Setup        | BigQuery Admin                      |
| Layer 2 | Detection Queries     | BigQuery User, Data Viewer          |
| Layer 3 | Remediation           | Instance Admin, Storage Admin       |
| Layer 3 | Revalidation          | Cloud Asset Viewer, BigQuery User   |

---

# Conclusion

The PoC demonstrated that a comprehensive governance framework can be implemented using native GCP services while maintaining a least-privilege access model.

The permissions required are well-defined, align with standard Google Cloud IAM practices, and eliminate the need for custom governance applications.

