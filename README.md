# GCP Governance PoC Repository Structure

## Repository Overview

This repository demonstrates a cloud-native governance framework implemented using Terraform and native Google Cloud capabilities, eliminating the need for custom applications.

The implementation covers:

* Layer 1 - Preventative Controls
* Layer 2 - Brownfield Detection
* Layer 3 - Remediation and Revalidation

---

# Repository Structure

```text
terraform-gcp-demo/
├── bootstrap/
├── docs/
├── evidence/
├── findings/
├── iam-deny/
├── org-policies/
├── scripts/
├── terraform/
├── README.md
├── terraform.sh
└── supporting files
```

---

# 1. bootstrap/

Purpose:

Bootstrap foundational governance artefacts required before enforcement.

```text
bootstrap
└── tags
```

Contents:

| File               | Purpose                           |
| ------------------ | --------------------------------- |
| list-tags.sh       | Lists all Tag Keys and Tag Values |
| main.tf            | Creates Tag Keys and Tag Values   |
| outputs.tf         | Outputs created tag identifiers   |
| provider.tf        | Provider configuration            |
| variables.tf       | Input variables                   |
| versions.tf        | Terraform version constraints     |
| terraform.tfstate* | Bootstrap state                   |

Responsibilities:

* Create Resource Manager Tag Keys
* Create approved Tag Values
* Establish organisation tagging standards

---

# 2. docs/

Purpose:

Customer-facing documentation.

```text
docs
├── layer-1
├── layer-2
├── layer-3
├── Required_Permissions_and_Roles.md
└── test_cases.md
```

Contents:

Layer 1:

Preventative governance controls.

Layer 2:

Brownfield detection.

Layer 3:

Remediation lifecycle.

Permissions:

Required IAM roles.

Test Cases:

End-to-end validation evidence.

Responsibilities:

* Operational guidance
* Customer handover
* Audit artefacts

---

# 3. evidence/

Purpose:

Proof that testing was performed.

```text
evidence
├── commands
├── screenshots
└── test-results
```

Contents:

Test outputs:

```text
application-values.txt
environment-values.txt
governance-deny-policies.txt
owner-values.txt
tag-bootstrap-output.txt
tag-keys.txt
```

Responsibilities:

* Audit evidence
* Demonstrate outcomes
* Support customer sign-off

---

# 4. findings/

Purpose:

Capture lessons learned and platform limitations.

```text
findings
├── enforce-mandatory-labels.yaml
├── supported-resource-matrix.md
├── test-results.md
└── test-update.yaml
```

Responsibilities:

* Document unsupported scenarios
* Track discoveries
* Record validation outcomes

Example Findings:

* Org Policies supported for VMs.
* Org Policies unsupported for Disks.
* IAM Deny successfully validated.

---

# 5. iam-deny/

Purpose:

Prevent unauthorised actions.

```text
iam-deny
├── deny-disk-governance.yaml
├── deny-snapshot-governance.yaml
└── deny-vm-governance.yaml
```

Responsibilities:

Prevent:

```text
VM creation
Disk creation
Snapshot creation

Label modifications

Tag binding changes
```

Governance Layer:

Layer 1

---

# 6. org-policies/

Purpose:

Enforce organisation-wide standards.

```text
org-policies
├── custom-constraints
└── policies
```

## custom-constraints/

Defines business logic.

Examples:

```text
environment-label.yaml
application-label.yaml
owner-label.yaml
```

Unsupported experiments:

```text
unsupported/
```

Responsibilities:

Validate:

```text
environment labels
owner labels
application labels
```

---

## policies/

Activates constraints.

Examples:

```text
environment-policy.yaml
application-policy.yaml
owner-policy.yaml
```

Responsibilities:

Turn constraints into enforcement.

Governance Layer:

Layer 1

---

# 7. scripts/

Purpose:

Operational automation.

```text
scripts
├── config.sh
├── delete-all.sh
├── disable-all.sh
├── enable-all.sh
└── verify-all.sh
```

Responsibilities:

Enable controls:

```text
./scripts/enable-all.sh
```

Disable controls:

```text
./scripts/disable-all.sh
```

Verification:

```text
./scripts/verify-all.sh
```

Cleanup:

```text
./scripts/delete-all.sh
```

---

# 8. terraform/

Purpose:

Infrastructure-as-Code implementation.

```text
terraform
├── environments
├── modules
└── state
```

---

## environments/

Environment-specific configurations.

```text
dev
test
uat
prod
```

Responsibilities:

Provide:

```text
environment
owner
application
```

values.

---

### dev/

Contains active PoC implementation.

Files:

```text
main.tf
variables.tf
locals.tf
dev.auto.tfvars
tag-test.tf
terraform.tfstate*
```

Responsibilities:

Deploy:

* VMs
* Disks
* Snapshots

Apply:

Mandatory labels.

---

# modules/

Reusable infrastructure components.

```text
compute-instance
compute-disk
compute-snapshot
storage-bucket
cloud-sql
tag-bindings
```

Responsibilities:

Encapsulate governance logic.

---

## compute-instance/

Deploy VMs.

Features:

* Mandatory labels
* Validation
* Outputs

---

## compute-disk/

Deploy disks.

Features:

* Mandatory labels
* Preconditions
* Outputs

---

## compute-snapshot/

Deploy snapshots.

Features:

* Mandatory labels
* Outputs

---

## tag-bindings/

Resource Manager Tags.

Features:

Attach:

```text
environment
owner
application
```

tags.

---

# state/

Stores Terraform state.

Contents:

```text
terraform.tfstate
terraform.tfstate.backup
```

Responsibilities:

Track deployed infrastructure.

---

# Root Files

## terraform.sh

Purpose:

Environment selector.

Example:

```bash
./terraform.sh plan
./terraform.sh apply
./terraform.sh destroy
```

Responsibilities:

Simplify deployments.

---

## README.md

Purpose:

Repository overview.

Responsibilities:

Describe:

* Architecture
* Objectives
* Findings
* Outcomes

---

## repo_source_dump.txt

Purpose:

Repository snapshot.

Responsibilities:

Documentation and troubleshooting.

---

## testdisk.log

Purpose:

Testing artefact.

Responsibilities:

Historical troubleshooting evidence.

---

# Governance Mapping

| Repository Area | Layer 1 | Layer 2 | Layer 3 |
| --------------- | ------: | ------: | ------: |
| bootstrap       |       ✓ |         |         |
| terraform       |       ✓ |         |         |
| iam-deny        |       ✓ |         |         |
| org-policies    |       ✓ |         |         |
| scripts         |       ✓ |         |         |
| docs/layer-1    |       ✓ |         |         |
| docs/layer-2    |         |       ✓ |         |
| docs/layer-3    |         |         |       ✓ |
| evidence        |       ✓ |       ✓ |       ✓ |
| findings        |       ✓ |       ✓ |       ✓ |

---

# Final Architecture

```text
Layer 1
Prevent
↓
Terraform + Org Policies + IAM Deny

Layer 2
Detect
↓
Cloud Asset Inventory + BigQuery

Layer 3
Remediate
↓
Fix Resources + Re-export + Revalidate
```

---

# Repository Outcome

This repository demonstrates an end-to-end cloud-native governance framework capable of:

* Preventing non-compliant resources.
* Detecting existing violations.
* Supporting remediation workflows.
* Producing audit evidence.
* Eliminating the need for custom Cloud Run governance applications.
# terraform-gcp-governance-raw
