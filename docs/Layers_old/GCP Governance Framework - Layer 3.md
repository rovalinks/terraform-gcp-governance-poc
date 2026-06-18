# GCP Governance Framework - Layer 3 Proof of Concept

## Brownfield Remediation Using Native GCP and Terraform

---

# Document Control

| Item           | Value                                  |
| -------------- | -------------------------------------- |
| Document Title | GCP Governance Framework - Layer 3 PoC |
| Version        | 1.0                                    |
| Prepared For   | Customer Review                        |
| Prepared By    | Cloud & Platform Engineering           |
| PoC Scope      | Layer 3 - Brownfield Remediation       |
| Status         | Completed                              |
| Outcome        | Successfully Validated                 |

---

# Executive Summary

Layer 3 demonstrates how brownfield resources identified during Layer 2 can be remediated using native Google Cloud capabilities and Terraform without introducing custom applications, Cloud Run services, or bespoke automation.

Two remediation approaches were validated:

* Terraform remediation for resources already managed within Terraform state.
* Native GCP remediation for resources created outside Terraform.

Following remediation activities, Cloud Asset Inventory exports were re-executed to verify that previously non-compliant resources no longer appeared within compliance findings.

All Layer 3 validation scenarios passed successfully.

---

# Objectives

The objectives of Layer 3 were to:

* Demonstrate remediation of brownfield resources.
* Validate Terraform-based remediation workflows.
* Validate native GCP remediation workflows.
* Verify that label updates occur without resource recreation.
* Revalidate compliance after remediation.
* Demonstrate end-to-end governance lifecycle closure.

---

# Architecture

Brownfield Findings

↓

Terraform Remediation

OR

↓

Native GCP Remediation

↓

Cloud Asset Inventory Re-Export

↓

BigQuery Revalidation

↓

Updated Compliance Report

---

# Services Used

| Service               | Purpose                      |
| --------------------- | ---------------------------- |
| Terraform             | Remediate managed resources  |
| Cloud Asset Inventory | Re-export assets             |
| BigQuery              | Store inventory snapshots    |
| BigQuery SQL          | Revalidate compliance        |
| gcloud CLI            | Native remediation           |
| bq CLI                | BigQuery Dataset remediation |

No Cloud Run services or custom applications were required.

---

# Scope

The following resource types were evaluated:

* Compute Engine Virtual Machines
* Persistent Disks
* BigQuery Datasets

Remediation approaches:

## Scenario A

Terraform-managed resources.

## Scenario B

Non-Terraform resources created through Console, CLI, or unmanaged processes.

Mandatory governance attributes:

| Attribute   | Purpose                |
| ----------- | ---------------------- |
| environment | Deployment environment |
| owner       | Resource ownership     |
| application | Business application   |

---

# Environment Details

| Item            | Value                          |
| --------------- | ------------------------------ |
| Organisation ID | 321880981428                   |
| Project ID      | project-a9c3b175-7f78-4ba6-9ad |
| Project Number  | 106228803995                   |
| Region          | europe-west2                   |
| Zone            | europe-west2-a                 |

---

# Scenario A - Terraform Managed Resources

Resources already under Terraform state management were remediated using the standard Infrastructure-as-Code workflow.

For most supported GCP resources, label updates occur in-place and do not trigger resource recreation.

---

## Control 1 - Add Mandatory Labels

### Objective

Add governance labels to Terraform-managed resources.

Resource:

```text id="l4uvop"
legacy-vm
```

Implementation:

Open:

```text id="z0vc3e"
terraform/environments/dev/main.tf
```

Add:

```hcl id="xqek2k"
labels = {
  environment = var.environment
  owner        = var.owner
  application  = var.application
}
```

Expected Result:

Terraform detects in-place update.

Actual Result:

Code modified successfully.

Outcome:

Remediation initiated.

Status:

VALIDATED

---

## Control 2 - Terraform Plan Validation

### Objective

Validate remediation changes prior to deployment.

Command:

```bash id="g2r3d0"
./terraform.sh plan
```

Expected Result:

Label additions visible.

Actual Result:

```text id="r89v5e"
~ labels = {
    + "application" = "payments"
    + "environment" = "dev"
    + "owner"       = "platform-team"
}
```

Outcome:

Remediation changes reviewed before execution.

Status:

VALIDATED

---

## Control 3 - Terraform Apply Validation

### Objective

Apply remediation changes.

Command:

```bash id="mq89gv"
./terraform.sh apply
```

Expected Result:

Labels applied without resource recreation.

Actual Result:

```text id="xq6cx6"
Apply complete!
Resources: 3 added, 1 changed, 0 destroyed.
```

Outcome:

Labels successfully applied.

Status:

VALIDATED

---

## Control 4 - Post-Remediation Verification

### Objective

Verify labels after Terraform remediation.

Command:

```bash id="m1m9qj"
gcloud compute instances describe legacy-vm \
  --zone=europe-west2-a \
  --format="yaml(labels)"
```

Expected Result:

```yaml id="3w0rzk"
environment: dev
owner: platform-team
application: payments
```

Actual Result:

```yaml id="7uv8mu"
labels:
  application: payments
  environment: dev
  goog-terraform-provisioned: 'true'
  owner: platform-team
```

Outcome:

Remediation verified successfully.

Status:

VALIDATED

---

# Scenario B - Non-Terraform Resources

Resources not managed through Terraform were remediated using native Google Cloud commands.

Native update operations are additive and do not overwrite unrelated labels.

---

## Control 5 - Native Compute Instance Remediation

### Objective

Remediate unmanaged Compute Engine instances.

Command:

```bash id="l8b2c2"
gcloud compute instances update vm-no-labels-l3 \
  --zone=europe-west2-a \
  --update-labels=environment=dev,owner=platform-team,application=payments
```

Verification:

```bash id="9d72tr"
gcloud compute instances describe vm-no-labels-l3 \
  --zone=europe-west2-a \
  --format="yaml(labels)"
```

Expected Result:

Instance updated successfully.

Actual Result:

```text id="f3dn9w"
Updating labels of instance [vm-no-labels-l3]...done.
```

Outcome:

Instance remediated successfully.

Status:

VALIDATED

---

## Control 6 - Native Persistent Disk Remediation

### Objective

Remediate unmanaged Persistent Disks.

Command:

```bash id="9br9wb"
gcloud compute disks update disk-no-labels-l3 \
  --zone=europe-west2-a \
  --update-labels=environment=dev,owner=platform-team,application=payments
```

Verification:

```bash id="ghry8h"
gcloud compute disks describe disk-no-labels-l3 \
  --zone=europe-west2-a \
  --format="yaml(labels)"
```

Expected Result:

Disk updated successfully.

Actual Result:

```text id="ujvcv2"
Updating labels of disk [disk-no-labels-l3]...done.
```

Outcome:

Persistent Disk remediated successfully.

Status:

VALIDATED

---

## Control 7 - Native BigQuery Dataset Remediation

### Objective

Remediate unmanaged BigQuery Datasets.

Command:

```bash id="naxsiv"
bq update \
  --set_label environment:dev \
  --set_label owner:platform-team \
  --set_label application:payments \
  project-a9c3b175-7f78-4ba6-9ad:governance_inventory_l3
```

Verification:

```bash id="n6e7my"
bq show --format=prettyjson \
project-a9c3b175-7f78-4ba6-9ad:governance_inventory_l3 \
| grep -A 5 '"labels"'
```

Expected Result:

Dataset updated successfully.

Actual Result:

```text id="hhlj80"
Dataset successfully updated.
```

Outcome:

Dataset remediated successfully.

Status:

VALIDATED

---

# Revalidation

Following remediation activities, Layer 2 detection processes were re-executed.

---

## Control 8 - Cloud Asset Re-Export

### Objective

Refresh governance inventory.

Action:

Re-execute Layer 2 Cloud Asset Inventory export.

Expected Result:

Updated asset inventory generated.

Actual Result:

Export completed successfully.

Outcome:

Inventory refreshed.

Status:

VALIDATED

---

## Control 9 - Compliance Revalidation

### Objective

Verify previously non-compliant resources no longer appear.

Validation Query:

```sql id="n3f7wx"
SELECT
  asset_type,
  name
FROM asset_export
WHERE
      JSON_VALUE(resource.data,'$.labels.environment') IS NULL
   OR JSON_VALUE(resource.data,'$.labels.owner') IS NULL
   OR JSON_VALUE(resource.data,'$.labels.application') IS NULL;
```

Expected Result:

Previously remediated resources disappear from findings.

Actual Result:

Remediated resources no longer returned.

Outcome:

Compliance successfully restored.

Status:

VALIDATED

---

# Layer 3 Test Results

| Test Scenario                            | Expected Result  | Actual Result    | Status |
| ---------------------------------------- | ---------------- | ---------------- | ------ |
| Add labels to Terraform-managed resource | Successful       | Successful       | ✅      |
| Terraform plan remediation validation    | Labels visible   | Labels visible   | ✅      |
| Terraform apply remediation validation   | In-place update  | Successful       | ✅      |
| Verify labels after apply                | Labels present   | Labels present   | ✅      |
| Native Compute remediation               | Successful       | Successful       | ✅      |
| Native Persistent Disk remediation       | Successful       | Successful       | ✅      |
| Native BigQuery Dataset remediation      | Successful       | Successful       | ✅      |
| Cloud Asset re-export                    | Successful       | Successful       | ✅      |
| Revalidation after remediation           | Findings cleared | Findings cleared | ✅      |

---

# Findings

## Terraform Remediation

Status:

```text id="wqcp1f"
SUPPORTED
```

Provides controlled remediation through Infrastructure-as-Code.

---

## Native GCP Remediation

Status:

```text id="xf0q8s"
SUPPORTED
```

Allows brownfield resources to be remediated without Terraform adoption.

---

## In-Place Metadata Updates

Status:

```text id="9i2l0m"
SUPPORTED
```

Label remediation did not require resource recreation.

---

## Compliance Revalidation

Status:

```text id="fww43z"
SUPPORTED
```

Previously detected resources no longer appeared following remediation.

---

# Layer 3 Outcome

Layer 3 successfully demonstrated that brownfield resources identified during Layer 2 can be remediated using native Google Cloud services and Terraform.

The following remediation lifecycle was validated:

Detect

↓

Remediate

↓

Re-Export

↓

Revalidate

↓

Restore Compliance

---

# Customer Sign-Off

| Item                    | Status   |
| ----------------------- | -------- |
| Terraform Remediation   | Accepted |
| Native GCP Remediation  | Accepted |
| Compliance Revalidation | Accepted |
| Layer 3 Overall Outcome | Accepted |

Customer Representative:

---

Date:

---

Signature:

---

---

# Conclusion

Layer 3 proved that brownfield governance findings can be remediated using standard operational practices without introducing custom applications or bespoke automation.

By combining Terraform-based remediation with native Google Cloud update capabilities, organisations can progressively improve governance posture while preserving existing workloads and operational processes.
