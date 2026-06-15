# Governance PoC - Detailed Test Matrix (Excel Copy Format)

**Project:** GCP Governance PoC - Eliminating Custom Code Using Cloud-Native Controls

**Organisation ID:** 321880981428

**Project ID:** project-a9c3b175-7f78-4ba6-9ad

---

## Layer 1 - Preventative Controls

| Test ID | Layer   | Test Scenario                         | Objective                                           | Preconditions        | Commands / Steps                                             | Expected Result            | Actual Result             | Status |
| ------- | ------- | ------------------------------------- | --------------------------------------------------- | -------------------- | ------------------------------------------------------------ | -------------------------- | ------------------------- | ------ |
| L1-001  | Layer 1 | Invalid Environment Validation        | Verify Terraform blocks invalid environments        | Terraform configured | Update tfvars: `environment="demo"` → `./terraform.sh plan`  | Validation error displayed | Validation error received | PASS   |
| L1-002  | Layer 1 | Valid Environment Validation          | Verify approved environments are accepted           | Terraform configured | Set environment to dev/test/uat/prod → `./terraform.sh plan` | Plan succeeds              | Plan succeeded            | PASS   |
| L1-003  | Layer 1 | Mandatory Labels Injection - VM       | Verify VM labels applied automatically              | Terraform configured | `./terraform.sh apply` → Describe VM                         | Labels present             | Labels present            | PASS   |
| L1-004  | Layer 1 | Mandatory Labels Injection - Disk     | Verify Disk labels applied automatically            | Terraform configured | Apply → Describe disk                                        | Labels present             | Labels present            | PASS   |
| L1-005  | Layer 1 | Mandatory Labels Injection - Snapshot | Verify Snapshot labels applied automatically        | Terraform configured | Apply → Describe snapshot                                    | Labels present             | Labels present            | PASS   |
| L1-006  | Layer 1 | Terraform Plan Governance Changes     | Verify governance changes visible before deployment | Existing resources   | Change owner → `./terraform.sh plan`                         | Label changes shown        | Changes visible           | PASS   |
| L1-007  | Layer 1 | Org Policy VM Without Labels          | Prevent VM creation without labels                  | Org policies enabled | Create VM without labels                                     | Denied                     | Denied                    | PASS   |
| L1-008  | Layer 1 | Org Policy VM Partial Labels          | Prevent partial compliance                          | Org policies enabled | Create VM with environment only                              | Denied                     | Denied                    | PASS   |
| L1-009  | Layer 1 | Org Policy VM Valid Labels            | Allow compliant VM                                  | Org policies enabled | Create VM with all labels                                    | Created                    | Created                   | PASS   |
| L1-010  | Layer 1 | IAM Deny VM Create                    | Validate Deny Policy                                | Deny enabled         | Create VM                                                    | Permission denied          | Permission denied         | PASS   |
| L1-011  | Layer 1 | IAM Deny Disk Create                  | Validate Deny Policy                                | Deny enabled         | Create disk                                                  | Permission denied          | Permission denied         | PASS   |
| L1-012  | Layer 1 | IAM Deny Snapshot Create              | Validate Deny Policy                                | Deny enabled         | Create snapshot                                              | Permission denied          | Permission denied         | PASS   |

---

## Layer 1 Commands

### Terraform Validation

```bash
./terraform.sh plan
```

---

### Terraform Apply

```bash
./terraform.sh apply
```

---

### Verify VM Labels

```bash
gcloud compute instances describe dev-tagging-vm-01 \
  --zone=europe-west2-a \
  --format="yaml(labels)"
```

---

### Verify Disk Labels

```bash
gcloud compute disks describe dev-tagging-disk-01 \
  --zone=europe-west2-a \
  --format="yaml(labels)"
```

---

### Verify Snapshot Labels

```bash
gcloud compute snapshots describe dev-tagging-snapshot-01 \
  --format="yaml(labels)"
```

---

### VM Without Labels

```bash
gcloud compute instances create vm-no-labels \
  --zone=europe-west2-a \
  --machine-type=e2-micro \
  --image-family=debian-12 \
  --image-project=debian-cloud
```

---

### VM Partial Labels

```bash
gcloud compute instances create vm-partial \
  --zone=europe-west2-a \
  --machine-type=e2-micro \
  --image-family=debian-12 \
  --image-project=debian-cloud \
  --labels=environment=dev
```

---

### VM Valid Labels

```bash
gcloud compute instances create vm-valid \
  --zone=europe-west2-a \
  --machine-type=e2-micro \
  --image-family=debian-12 \
  --image-project=debian-cloud \
  --labels=environment=dev,owner=platform-team,application=payments
```

---

## Layer 2 - Brownfield Detection

| Test ID | Layer   | Test Scenario              | Objective                      | Preconditions    | Commands / Steps   | Expected Result   | Actual Result | Status |
| ------- | ------- | -------------------------- | ------------------------------ | ---------------- | ------------------ | ----------------- | ------------- | ------ |
| L2-001  | Layer 2 | Create BigQuery Dataset    | Prepare inventory repository   | APIs enabled     | Create dataset     | Dataset created   | Created       | PASS   |
| L2-002  | Layer 2 | Export Asset Inventory     | Export metadata to BigQuery    | Dataset exists   | Asset export       | Export succeeds   | Success       | PASS   |
| L2-003  | Layer 2 | Validate Export Completion | Verify export completed        | Export initiated | Describe operation | done:true         | done:true     | PASS   |
| L2-004  | Layer 2 | Validate Resource Counts   | Confirm inventory completeness | Export complete  | Count assets       | Counts returned   | Returned      | PASS   |
| L2-005  | Layer 2 | Detect Missing Owner       | Find owner violations          | Export complete  | Query inventory    | Findings returned | Returned      | PASS   |
| L2-006  | Layer 2 | Detect Missing Environment | Find environment violations    | Export complete  | Query inventory    | Findings returned | Returned      | PASS   |
| L2-007  | Layer 2 | Detect Missing Application | Find application violations    | Export complete  | Query inventory    | Findings returned | Returned      | PASS   |
| L2-008  | Layer 2 | Detect Any Missing Label   | Consolidated detection         | Export complete  | Combined query     | Findings returned | Returned      | PASS   |

---

## Layer 2 Commands

### Create Dataset

```bash
bq mk \
  --location=europe-west2 \
  governance_inventory_l3
```

---

### Export Assets

```bash
gcloud asset export \
  --project=project-a9c3b175-7f78-4ba6-9ad \
  --content-type=resource \
  --asset-types="compute.googleapis.com/Instance,compute.googleapis.com/Disk,compute.googleapis.com/Snapshot" \
  --bigquery-table="projects/project-a9c3b175-7f78-4ba6-9ad/datasets/governance_inventory_l3/tables/asset_export" \
  --output-bigquery-force
```

---

### Check Export Status

```bash
gcloud asset operations describe \
projects/106228803995/operations/ExportAssets/RESOURCE/<OPERATION_ID> \
--format="yaml(done,error,response)"
```

---

### Asset Counts

```sql
SELECT
  asset_type,
  COUNT(*) total
FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory_l3.asset_export`
GROUP BY asset_type;
```

---

### Missing Owner

```sql
SELECT
  name,
  asset_type
FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory_l3.asset_export`
WHERE NOT REGEXP_CONTAINS(resource.data, '"owner"');
```

---

### Missing Environment

```sql
SELECT
  name,
  asset_type
FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory_l3.asset_export`
WHERE NOT REGEXP_CONTAINS(resource.data, '"environment"');
```

---

### Missing Application

```sql
SELECT
  name,
  asset_type
FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory_l3.asset_export`
WHERE NOT REGEXP_CONTAINS(resource.data, '"application"');
```

---

### Missing Any Label

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

## Layer 3 - Remediation and Revalidation

| Test ID | Layer   | Test Scenario        | Objective                       | Preconditions       | Commands / Steps        | Expected Result | Actual Result | Status |
| ------- | ------- | -------------------- | ------------------------------- | ------------------- | ----------------------- | --------------- | ------------- | ------ |
| L3-001  | Layer 3 | Create Brownfield VM | Simulate non-compliant resource | Detection available | Create VM missing owner | VM created      | Created       | PASS   |
| L3-002  | Layer 3 | Detect Brownfield VM | Verify detection                | Export complete     | Missing owner query     | VM returned     | Returned      | PASS   |
| L3-003  | Layer 3 | Manual Remediation   | Fix owner label                 | Brownfield exists   | Add owner label         | Label updated   | Updated       | PASS   |
| L3-004  | Layer 3 | Verify Remediation   | Confirm label applied           | Remediated          | Describe VM             | Owner present   | Present       | PASS   |
| L3-005  | Layer 3 | Re-export Assets     | Refresh inventory               | VM remediated       | Asset export            | Export succeeds | Success       | PASS   |
| L3-006  | Layer 3 | Revalidation         | Ensure VM disappears            | Export complete     | Detection query         | VM absent       | Absent        | PASS   |

---

## Layer 3 Commands

### Verify Brownfield VM

```bash
gcloud compute instances describe brownfield-vm-01 \
  --zone=europe-west2-a \
  --format="yaml(labels)"
```

---

### Add Missing Owner

```bash
gcloud compute instances add-labels brownfield-vm-01 \
  --zone=europe-west2-a \
  --labels=owner=platform-team
```

---

### Verify Remediation

```bash
gcloud compute instances describe brownfield-vm-01 \
  --zone=europe-west2-a \
  --format="yaml(labels)"
```

---

### Re-export Assets

```bash
gcloud asset export \
  --project=project-a9c3b175-7f78-4ba6-9ad \
  --content-type=resource \
  --asset-types="compute.googleapis.com/Instance,compute.googleapis.com/Disk,compute.googleapis.com/Snapshot" \
  --bigquery-table="projects/project-a9c3b175-7f78-4ba6-9ad/datasets/governance_inventory_l3/tables/asset_export" \
  --output-bigquery-force
```

---

### Final Revalidation

```sql
SELECT
  name,
  asset_type
FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory_l3.asset_export`
WHERE NOT REGEXP_CONTAINS(resource.data, '"owner"');
```

Expected:

```text
brownfield-vm-01 should no longer appear.
```

---

# PoC Summary

| Layer       | Total Tests | Passed | Failed |
| ----------- | ----------: | -----: | -----: |
| Layer 1     |          12 |     12 |      0 |
| Layer 2     |           8 |      8 |      0 |
| Layer 3     |           6 |      6 |      0 |
| **Overall** |      **26** | **26** |  **0** |

**PoC Result: SUCCESS**

