# GCP Governance Accelerator

## Overview

This repository provides a plug-and-play GCP Governance Accelerator built using Terraform, IAM Deny Policies, Organisation Policies, Resource Manager Tags, Cloud Asset Inventory and BigQuery.

The solution enables organisations to enforce governance controls with minimal customisation.

---

## Features

* Mandatory labels enforcement
* Resource Manager Tag governance
* IAM Deny Policies
* Cloud Asset Inventory exports
* BigQuery governance inventory
* Terraform-based deployment
* Multi-environment support
* Customer configurable deployment

---

## Architecture

Components:

* Terraform Infrastructure
* Resource Manager Tags
* Organisation Policies
* IAM Deny Policies
* Cloud Asset Inventory
* BigQuery Dataset
* Cloud Workflows
* Cloud Scheduler

---

## Repository Structure

```text
bootstrap/
config/
terraform/
scripts/
asset-export/
org-policies/
iam-deny/
docs/
```

---

## Prerequisites

* GCP Organisation
* Terraform >= 1.5
* gcloud CLI
* Organisation Administrator permissions
* Project Owner permissions

---

## Customer Configuration

Update:

config/customer.auto.tfvars

Example:

project_id
project_number
org_id
region
zone

---

## Bootstrap Deployment

```bash
cd bootstrap
terraform init
terraform apply
```

---

## Governance Deployment

```bash
./terraform.sh plan
./terraform.sh apply
```

---

## Enable Governance Controls

```bash
./scripts/enable-all.sh
```

---

## Validation

```bash
./scripts/verify-all.sh
```

---

## Cleanup

```bash
./scripts/disable-all.sh
./scripts/delete-all.sh
```

---

## Supported Environments

* dev
* test
* uat
* prod

---

## Outcome

The solution provides a reusable governance framework that can be deployed into any GCP organisation with minimal configuration changes.
