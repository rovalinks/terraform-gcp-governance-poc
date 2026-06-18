# GCP Governance Accelerator - Deployment Guide

## Overview

This guide explains how to deploy the GCP Governance Accelerator into a new customer environment.

The deployment consists of:

1. Customer Configuration
2. Bootstrap Deployment
3. Governance Deployment
4. Governance Enablement
5. Validation

---

# Prerequisites

## Required Access

The deployment user must have:

* Organisation Administrator
* Project Owner
* Billing Administrator (if creating projects)
* IAM Administrator
* Tag Administrator
* Org Policy Administrator

## Required Tools

* Terraform >= 1.5
* Google Cloud SDK (gcloud)
* Git
* Bash Shell

---

# Step 1 - Clone Repository

```bash
git clone https://github.com/rovalinks/terraform-gcp-governance-poc

cd terraform-gcp-governance-poc

git pull origin feature/plug-and-play

git checkout  feature/plug-and-play
```

---

# Step 2 - Authenticate

```bash
gcloud auth login

gcloud auth application-default login
```

Configure project:

```bash
gcloud config set project <PROJECT_ID>
```

---

# Step 3 - Configure Customer Settings

Update:

```text
config/customer.auto.tfvars
```

Example:

```hcl
org_id         = "123456789012"
project_id     = "customer-project"
project_number = "123456789"

region = "europe-west2"
zone   = "europe-west2-a"
```

---

# Step 4 - Generate Environment Configuration

Run:

```bash
./scripts/generate-environment-config.sh
```

This generates:

```text
terraform/environments/dev/customer.auto.tfvars
terraform/environments/test/customer.auto.tfvars
terraform/environments/uat/customer.auto.tfvars
terraform/environments/prod/customer.auto.tfvars
```

---

# Step 5 - Deploy Bootstrap Components

Bootstrap creates:

* Tag Keys
* Tag Values

Navigate:

```bash
cd bootstrap/tags
```

Initialise Terraform:

```bash
terraform init
```

Deploy:

```bash
terraform apply
```

Verify tags:

```bash
./list-tags.sh
```

---

# Step 6 - Deploy Governance Infrastructure

Return to repository root:

```bash
cd ../..
```

Run:

```bash
./terraform.sh plan
```

Select environment:

```text
1) dev
2) test
3) uat
4) prod
```

Apply:

```bash
./terraform.sh apply
```

Resources created include:

* Compute Instances
* Persistent Disks
* Snapshots
* Tag Bindings
* BigQuery Datasets

---

# Step 7 - Generate Governance Files

Run:

```bash
./scripts/generate-org-policies.sh

./scripts/generate-deny-policies.sh
```

---

# Step 8 - Enable Governance Controls

Run:

```bash
./scripts/enable-all.sh
```

This deploys:

* Custom Constraints
* Organisation Policies
* IAM Deny Policies

---

# Step 9 - Validate Deployment

Run:

```bash
./scripts/verify-all.sh
```

Validate:

* Tag Keys
* Tag Values
* Organisation Policies
* IAM Deny Policies
* BigQuery Datasets

---

# Step 10 - Deploy Asset Inventory Export

Navigate:

```bash
cd asset-export
```

Deploy:

```bash
./deploy.sh
```

This deploys:

* Cloud Workflows
* Cloud Scheduler Jobs
* Asset Inventory Export

---

# Troubleshooting

## Terraform Variable Prompts

Verify:

```text
customer.auto.tfvars
```

exists in the environment folder.

---

## Tag Binding Failures

Verify bootstrap deployment completed successfully.

---

## IAM Deny Policy Errors

Verify:

* Project Number
* Organisation Permissions
* IAM API enabled

---

# Cleanup

Disable governance controls:

```bash
./scripts/disable-all.sh
```

Delete governance controls:

```bash
./scripts/delete-all.sh
```

Destroy Terraform resources:

```bash
./terraform.sh destroy
```
