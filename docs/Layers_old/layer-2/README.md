# Layer 2 - Brownfield Detection Using Cloud Asset Inventory

## Overview

Layer 2 provides brownfield detection capabilities using native Google Cloud services without requiring custom applications or runtime components.

The implementation exports Cloud Asset Inventory resource metadata, including labels, into BigQuery and uses standard SQL queries to identify non-compliant resources.

---

## Architecture

Cloud Asset Inventory
↓
BigQuery Export
↓
BigQuery SQL
↓
Brownfield Detection

---

## Services Used

| Service               | Purpose                  |
| --------------------- | ------------------------ |
| Cloud Asset Inventory | Export resource metadata |
| BigQuery              | Store exported assets    |
| BigQuery SQL          | Detect missing labels    |
| gcloud CLI            | Execute exports          |
| bq CLI                | Query exported data      |

No Cloud Run services or custom applications are required.

---

## APIs Enabled

```bash
gcloud services enable \
    cloudasset.googleapis.com \
    bigquery.googleapis.com
```

---

## BigQuery Dataset

Dataset Name:

```text
governance_inventory
```

Location:

```text
europe-west2
```

Creation:

```bash
bq mk \
    --location=europe-west2 \
    governance_inventory
```

---

## Cloud Asset Export

Validated export command:

```bash
gcloud asset export \
    --project=project-a9c3b175-7f78-4ba6-9ad \
    --content-type=resource \
    --asset-types="compute.googleapis.com/Instance,compute.googleapis.com/Disk,compute.googleapis.com/Snapshot" \
    --bigquery-table="projects/project-a9c3b175-7f78-4ba6-9ad/datasets/governance_inventory/tables/asset_export" \
    --output-bigquery-force
```

---

## Export Validation

The export completed successfully using the Cloud Asset Inventory service agent.

Service Agent:

```text
service-106228803995@gcp-sa-cloudasset.iam.gserviceaccount.com
```

BigQuery Load Job:

| Attribute         | Value                             |
| ----------------- | --------------------------------- |
| Status            | Success                           |
| Duration          | 11 seconds                        |
| Source Format     | NEWLINE_DELIMITED_JSON            |
| Destination Table | governance_inventory.asset_export |

---

## Export Verification

Exported row count:

```bash
bq query \
    --location=europe-west2 \
    --use_legacy_sql=false \
    '
    SELECT COUNT(*) total
    FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory.asset_export`
    '
```

Result:

```text
12 resources exported
```

---

## Exported Resource Types

Validated resource types:

* Compute Engine Instances
* Persistent Disks
* Snapshots

---

## Label Validation

Labels were successfully exported within resource metadata.

Validation query:

```bash
bq query \
    --location=europe-west2 \
    --use_legacy_sql=false \
    '
    SELECT
      name,
      asset_type,
      resource.data
    FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory.asset_export`
    LIMIT 1
    '
```

Sample output:

```json
"labels": {
    "application": "payments",
    "environment": "dev",
    "owner": "platform-team"
}
```

---

## Compliance Detection Queries

Missing environment label:

```sql
SELECT
    name,
    asset_type
FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory.asset_export`
WHERE NOT REGEXP_CONTAINS(resource.data, '"environment"');
```

Missing owner label:

```sql
SELECT
    name,
    asset_type
FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory.asset_export`
WHERE NOT REGEXP_CONTAINS(resource.data, '"owner"');
```

Missing application label:

```sql
SELECT
    name,
    asset_type
FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory.asset_export`
WHERE NOT REGEXP_CONTAINS(resource.data, '"application"');
```

All non-compliant resources:

```sql
SELECT
    name,
    asset_type
FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory.asset_export`
WHERE NOT REGEXP_CONTAINS(resource.data, '"environment"')
   OR NOT REGEXP_CONTAINS(resource.data, '"owner"')
   OR NOT REGEXP_CONTAINS(resource.data, '"application"');
```

---

## Known Findings

### Project-Level Export

Project-level Cloud Asset Inventory export to BigQuery was successfully validated.

Status:

```text
SUPPORTED
```

---

### Organisation-Level Export

Organisation-level export using:

```bash
--per-asset-type
```

returned:

```text
INVALID_ARGUMENT
```

within the tested environment and was not validated as part of this PoC.

Status:

```text
NOT VALIDATED
```

---

## Layer 2 PoC Outcome

Layer 2 successfully demonstrated that brownfield resources can be detected using fully managed Google Cloud services and standard tooling.

No custom code, Cloud Run services, or bespoke applications were required.

