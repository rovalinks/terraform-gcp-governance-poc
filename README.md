# GCP Governance PoC - Eliminating Custom Code Using Cloud-Native Controls

## Overview

This repository contains a Proof of Concept (PoC) demonstrating how governance requirements can be implemented using native Google Cloud Platform (GCP) capabilities and Terraform, without building and maintaining custom applications.

The objective of this PoC is to enforce mandatory metadata standards, validate approved values, provide resource classification capabilities, and restrict unauthorised resource creation using cloud-native controls.

---

## Objectives

* Eliminate the need for custom Cloud Run applications for governance enforcement.
* Enforce mandatory metadata standards across infrastructure resources.
* Validate approved environment values.
* Demonstrate governance controls for both Infrastructure-as-Code and direct CLI/API users.
* Evaluate the applicability and limitations of GCP native controls.
* Provide evidence-based recommendations for enterprise implementation.

---

## Scope

The following GCP resource types were included in this PoC:

* Compute Engine Virtual Machines
* Compute Engine Zonal Persistent Disks
* Compute Engine Snapshots

---

## Governance Controls Evaluated

### 1. Terraform Validation

Terraform variable validation was implemented to enforce approved environment values before infrastructure provisioning.

Approved values:

* dev
* test
* uat
* prod

Example invalid values:

* km
* demo
* production

---

### 2. Terraform Mandatory Labels

Terraform modules automatically inject mandatory labels into supported resources.

Mandatory labels:

* environment
* owner
* application

Example:

```hcl
labels = {
  environment = var.environment
  owner        = var.owner
  application  = var.application
}
```

---

### 3. Native GCP Behaviour Assessment

Direct GCP CLI testing was performed to understand default platform behaviour.

The following scenarios were evaluated:

* Resource creation without labels
* Resource creation with mandatory labels
* Resource creation with invalid label values

---

### 4. Resource Manager Tags

Resource Manager Tags were evaluated to determine support across resource types and to assess their suitability for future governance and policy use cases.

Example Tag:

```text
environment=dev
```

---

### 5. IAM Deny Policies

IAM Deny Policies were evaluated as preventative controls to block unauthorised resource creation.

Permissions tested:

* compute.googleapis.com/instances.create
* compute.googleapis.com/disks.create
* compute.googleapis.com/snapshots.create

---

### 6. Custom Organization Policy Constraints

Custom Organization Policy Constraints were evaluated to determine support for enforcing mandatory labels during direct CLI/API resource creation.

Findings:

* Compute Engine VM: Supported
* Persistent Disk: Not Supported
* Snapshot: Not Supported

---

## Repository Structure

```text
terraform-gcp-demo/
├── terraform/
│   ├── environments/
│   │   ├── dev/
│   │   ├── test/
│   │   ├── uat/
│   │   └── prod/
│   └── modules/
├── modules/
│   ├── compute-instance/
│   ├── compute-disk/
│   └── compute-snapshot/
├── org-policies/
│   ├── custom-constraints/
│   └── policies/
├── iam-deny/
├── terraform.sh
├── README.md
└── .gitignore
```

---

## Deployment Process

Terraform deployments are executed using the helper script:

```bash
./terraform.sh plan
./terraform.sh apply
./terraform.sh destroy
```

The script prompts users to select an environment:

* dev
* test
* uat
* prod

---

## Testing Approach

Testing was conducted in the following sequence:

```text
Terraform Validation
↓
Terraform Mandatory Labels
↓
Native CLI Behaviour
↓
Resource Manager Tags
↓
IAM Deny Policies
```

---

## Summary of Findings

| Resource          | Terraform Validation | Terraform Labels | Native CLI Assessment | Resource Manager Tags | IAM Deny | Org Policy Custom Constraint |
| ----------------- | -------------------: | ---------------: | --------------------: | --------------------: | -------: | ---------------------------: |
| Compute Engine VM |                  Yes |              Yes |                   Yes |                   Yes |      Yes |                          Yes |
| Persistent Disk   |                  Yes |              Yes |                   Yes |                   Yes |      Yes |                           No |
| Snapshot          |                  Yes |              Yes |                   Yes |                   Yes |      Yes |                           No |

---

## Key Findings

* Native GCP does not enforce business-specific label requirements by default.
* Terraform validation effectively protects Infrastructure-as-Code deployments.
* Terraform modules can automatically inject mandatory labels.
* Resource Manager Tags provide additional classification capabilities.
* IAM Deny Policies successfully block unauthorised resource creation after policy propagation.
* Custom Organization Policy Constraints can enforce mandatory labels for Compute Engine VMs but are not universally supported across all resource types.
* A layered governance approach is required to achieve comprehensive coverage.

---

## Recommended Governance Architecture

### Terraform Users

```text
Terraform Validation
↓
Terraform Mandatory Labels
```

### Direct CLI/API Users

```text
Custom Organization Policy Constraints
↓
IAM Deny Policies
```

### Enterprise Governance Model

```text
Terraform Validation
↓
Terraform Mandatory Labels
↓
Custom Organization Policy Constraints
↓
Resource Manager Tags
↓
IAM Deny Policies
```

---

## Conclusion

This PoC demonstrates that enterprise governance requirements can be implemented using native GCP capabilities and Terraform without developing custom applications.

A combination of Terraform validation, automatic label injection, Custom Organization Policy Constraints, Resource Manager Tags, and IAM Deny Policies provides a scalable and maintainable governance framework aligned with cloud-native best practices.

---

## Disclaimer

This repository represents a Proof of Concept and should be adapted to organisational standards, security requirements, and operational processes before production implementation.
