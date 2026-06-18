# Terraform GCP Governance Accelerator

## Overview

This repository provides a reusable Google Cloud governance accelerator built using native Google Cloud services and Terraform.

The solution demonstrates how enterprise governance controls can be implemented without custom applications, Cloud Run services, or bespoke code.

The accelerator is organised into three governance layers:

### Layer 1 - Preventative Governance

Prevents non-compliant resources from being created using:

* Terraform validation
* Mandatory labels
* Tag bindings
* Custom Organisation Policies
* IAM Deny Policies

### Layer 2 - Brownfield Detection

Identifies existing non-compliant resources using:

* Cloud Asset Inventory
* BigQuery
* SQL-based compliance queries

### Layer 3 - Remediation

Demonstrates remediation of non-compliant resources and revalidation of compliance status.

---

# Solution Architecture

```text
Bootstrap Tags
      ↓

Terraform Deployment
      ↓

Labels + Tag Bindings
      ↓

Custom Organisation Policies
      ↓

IAM Deny Policies
      ↓

Cloud Asset Inventory
      ↓

BigQuery Export
      ↓

Compliance Detection
      ↓

Remediation
      ↓

Revalidation
```

---

# Repository Structure

```text
.
├── asset-export/
├── bootstrap/
│   └── tags/
├── config/
├── docs/
├── iam-deny/
├── modules/
├── org-policies/
├── scripts/
├── terraform/
│   └── environments/
│       ├── dev/
│       ├── test/
│       ├── uat/
│       └── prod/
└── README.md
```

---

# Prerequisites

The deployment account requires permissions to manage:

* Google Cloud Tags
* Organisation Policies
* IAM Deny Policies
* BigQuery
* Cloud Asset Inventory
* Cloud Workflows
* Cloud Scheduler
* Terraform Resources

Recommended roles:

* Organisation Policy Administrator
* Tag Administrator
* Security Admin
* Project IAM Admin
* BigQuery Admin
* Cloud Asset Inventory Admin
* Workflow Admin
* Scheduler Admin

---

# Configuration

Update the following files before deployment:

## Terraform Configuration

```text
config/customer.auto.tfvars
```

Example:

```hcl
project_id         = "customer-project"
project_number     = "123456789"
org_id             = "123456789012"

region             = "europe-west2"
zone               = "europe-west2-a"

environment        = "dev"

owner              = "platform-team"
application        = "payments"

inventory_dataset  = "governance_inventory"

workload_ids = [
  "01",
  "02"
]
```

---

## Governance Configuration

```text
scripts/config.sh
```

Example:

```bash
export PROJECT_ID="customer-project"

export PROJECT_NUMBER="123456789"

export ORGANIZATION_ID="123456789012"

export REGION="europe-west2"

export ZONE="europe-west2-a"

export GOVERNANCE_DATASET="governance_inventory"

export GOVERNANCE_ADMIN_EMAIL="admin@customer.com"
```

---

# Deployment Steps

## Step 1 - Bootstrap Tags

```bash
cd bootstrap/tags

terraform init

terraform apply
```

This creates:

* Tag Keys
* Tag Values

---

## Step 2 - Deploy Terraform Resources

```bash
cd terraform/environments/dev

./terraform.sh apply
```

This creates:

* Compute Instances
* Persistent Disks
* Snapshots
* Labels
* Tag Bindings

---

## Step 3 - Enable Governance Controls

```bash
./scripts/enable-all.sh
```

This enables:

* Custom Constraints
* Organisation Policies
* IAM Deny Policies

---

## Step 4 - Deploy Brownfield Detection

```bash
./asset-export/gcp-cai-lifecycle-manager.sh
```

This deploys:

* Cloud Workflows
* Cloud Scheduler
* Cloud Asset Inventory Export Automation

---

## Step 5 - Execute Validation Tests

Run the validation scenarios documented in:

```text
docs/test_cases.md
```

---

# Governance Layers

## Layer 1 - Preventative Governance

Validated controls:

* Terraform Validation
* Mandatory Labels
* Tag Bindings
* Custom Organisation Policies
* IAM Deny Policies

---

## Layer 2 - Brownfield Detection

Validated controls:

* Cloud Asset Inventory Export
* BigQuery Export
* Compliance Queries
* Brownfield Resource Detection

---

## Layer 3 - Remediation

Validated controls:

* Terraform Remediation
* Native GCP Remediation
* Compliance Revalidation

---

# Cleanup

Disable governance controls:

```bash
./scripts/disable-all.sh
```

Remove governance controls:

```bash
./scripts/delete-all.sh
```

Destroy Terraform resources:

```bash
cd terraform/environments/dev

terraform destroy
```

---

# Outcome

This accelerator demonstrates a cloud-native governance approach using managed Google Cloud services and Terraform.

The solution provides:

* Preventative governance
* Brownfield detection
* Remediation
* Compliance revalidation

without introducing custom applications or operational overhead.
