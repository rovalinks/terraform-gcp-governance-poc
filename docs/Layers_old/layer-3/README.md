# Layer 3 - Brownfield Remediation and Revalidation

## Overview

Layer 3 demonstrates how existing non-compliant resources identified through Layer 2 can be remediated and revalidated using native Google Cloud capabilities.

This layer validates the end-to-end governance lifecycle:

Brownfield Detection

↓

Manual Remediation

↓

Cloud Asset Re-Export

↓

Compliance Revalidation

No custom applications, Cloud Run services, or bespoke code are required.

---

# Objectives

The objectives of Layer 3 were to:

* Demonstrate identification of existing non-compliant resources.
* Validate remediation using native GCP tooling.
* Re-export updated resource metadata.
* Verify that remediated resources are no longer reported as non-compliant.
* Provide evidence that governance controls support continuous improvement.

---

# Architecture

Cloud Asset Inventory

↓

BigQuery Export

↓

SQL Detection Queries

↓

Manual Remediation

↓

Cloud Asset Re-Export

↓

Compliance Validation

---

# Environment

Project ID:

```text
project-a9c3b175-7f78-4ba6-9ad
```

BigQuery Dataset:

```text
governance_inventory_l3
```

BigQuery Table:

```text
asset_export
```

Region:

```text
europe-west2
```

---

# Scenario

A brownfield virtual machine was intentionally created with incomplete labels.

Resource:

```text
brownfield-vm-01
```

Applied Labels:

```text
environment=dev
application=payments
```

Missing Label:

```text
owner
```

Expected Behaviour:

The resource should be detected as non-compliant.

---

# Step 1 - Export Resource Metadata

Cloud Asset Inventory export was executed.

```bash
gcloud asset export \
  --project=project-a9c3b175-7f78-4ba6-9ad \
  --content-type=resource \
  --asset-types="compute.googleapis.com/Instance,compute.googleapis.com/Disk,compute.googleapis.com/Snapshot" \
  --bigquery-table="projects/project-a9c3b175-7f78-4ba6-9ad/datasets/governance_inventory_l3/tables/asset_export" \
  --output-bigquery-force
```

---

# Step 2 - Verify Export Completion

Operation status was validated.

Example:

```bash
gcloud asset operations describe \
projects/106228803995/operations/ExportAssets/RESOURCE/<OPERATION_ID> \
--format="yaml(done,error,response)"
```

Result:

```yaml
done: true
response:
  outputConfig:
    bigqueryDestination:
      dataset: projects/project-a9c3b175-7f78-4ba6-9ad/datasets/governance_inventory_l3
      table: asset_export
```

Result:

Successful export.

---

# Step 3 - Validate Exported Resource Counts

Query:

```bash
bq query \
--location=europe-west2 \
--use_legacy_sql=false \
'
SELECT
  asset_type,
  COUNT(*) total
FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory_l3.asset_export`
GROUP BY asset_type
'
```

Sample Result:

```text
compute.googleapis.com/Disk        6
compute.googleapis.com/Instance    2
compute.googleapis.com/Snapshot    6
```

Result:

Resource inventory successfully exported.

---

# Step 4 - Detect Non-Compliant Resources

## Missing Owner Label

Query:

```bash
bq query \
--location=europe-west2 \
--use_legacy_sql=false \
'
SELECT
  name,
  asset_type
FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory_l3.asset_export`
WHERE NOT REGEXP_CONTAINS(resource.data, "\"owner\"")
'
```

Result:

```text
brownfield-vm-01
```

Example Output:

```text
//compute.googleapis.com/.../instances/brownfield-vm-01
```

Outcome:

The intentionally non-compliant VM was successfully detected.

---

# Additional Compliance Queries

## Missing Environment Label

```sql
SELECT
  name,
  asset_type
FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory_l3.asset_export`
WHERE NOT REGEXP_CONTAINS(resource.data, '"environment"');
```

---

## Missing Application Label

```sql
SELECT
  name,
  asset_type
FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory_l3.asset_export`
WHERE NOT REGEXP_CONTAINS(resource.data, '"application"');
```

---

## Missing Any Mandatory Label

```sql
SELECT
  name,
  asset_type
FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory_l3.asset_export`
WHERE NOT REGEXP_CONTAINS(resource.data, '"environment"')
   OR NOT REGEXP_CONTAINS(resource.data, '"owner"')
   OR NOT REGEXP_CONTAINS(resource.data, '"application"');
```

---

# Step 5 - Manual Remediation

The missing owner label was added.

Command:

```bash
gcloud compute instances add-labels brownfield-vm-01 \
  --zone=europe-west2-a \
  --labels=owner=platform-team
```

---

# Step 6 - Verify Remediation

Validation:

```bash
gcloud compute instances describe brownfield-vm-01 \
  --zone=europe-west2-a \
  --format="yaml(labels)"
```

Result:

```yaml
labels:
  application: payments
  environment: dev
  owner: platform-team
```

Outcome:

VM successfully remediated.

---

# Step 7 - Re-Export Cloud Asset Inventory

Updated metadata was exported.

```bash
gcloud asset export \
  --project=project-a9c3b175-7f78-4ba6-9ad \
  --content-type=resource \
  --asset-types="compute.googleapis.com/Instance,compute.googleapis.com/Disk,compute.googleapis.com/Snapshot" \
  --bigquery-table="projects/project-a9c3b175-7f78-4ba6-9ad/datasets/governance_inventory_l3/tables/asset_export" \
  --output-bigquery-force
```

Outcome:

Inventory refreshed.

---

# Step 8 - Revalidate Compliance

The original detection query was executed again.

```bash
bq query \
--location=europe-west2 \
--use_legacy_sql=false \
'
SELECT
  name,
  asset_type
FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory_l3.asset_export`
WHERE NOT REGEXP_CONTAINS(resource.data, "\"owner\"")
'
```

Outcome:

The remediated VM no longer appeared in the findings.

---

# Remaining Findings

The following resources still appeared as non-compliant:

Persistent Disks:

```text
brownfield-vm-01
dev-tagging-vm-01
```

Snapshots:

```text
snapshot-no-labels
snapshot-cli-no-labels
```

Reason:

* Boot disk labels do not automatically inherit VM labels.
* Snapshot metadata remains independent of VM metadata.
* Separate remediation processes are required.

---

# Layer 3 Findings

## Brownfield Detection

Status:

```text
VALIDATED
```

Existing non-compliant resources were identified.

---

## Manual Remediation

Status:

```text
VALIDATED
```

Resources were successfully updated.

---

## Compliance Revalidation

Status:

```text
VALIDATED
```

Remediated resources disappeared from subsequent findings.

---

## Native GCP Capability

Status:

```text
VALIDATED
```

No custom applications were required.

---

# Layer 3 Outcome

Layer 3 successfully demonstrated the complete governance lifecycle for brownfield resources using native Google Cloud capabilities.

The following workflow was validated:

Detect

↓

Remediate

↓

Re-export

↓

Revalidate

This approach enables organisations to progressively improve governance posture without introducing bespoke applications or additional operational complexity.

---

# Conclusion

The Layer 3 PoC proved that Cloud Asset Inventory and BigQuery can be used not only for identifying non-compliant resources but also for validating remediation efforts.

Combined with Layer 1 preventative controls and Layer 2 detection capabilities, this establishes a comprehensive cloud-native governance framework capable of supporting enterprise governance requirements without the need for custom Cloud Run applications.
