# GCP Governance Accelerator - L1 Operator Guide

## Purpose

This guide is intended for Operations, Cloud Support, and L1/L2 teams responsible for monitoring and operating the Governance Accelerator after deployment.

The guide does not cover implementation details and focuses only on operational activities.

---

# Daily Checks

## Verify Governance Controls

Run:

```bash
./scripts/verify-all.sh
```

Expected Results:

* Custom Constraints Active
* Organisation Policies Active
* IAM Deny Policies Active
* Tag Keys Available
* Tag Values Available

---

## Verify Asset Export Jobs

Check Cloud Scheduler:

```bash
gcloud scheduler jobs list
```

Expected Jobs:

* cai-export-job
* cai-cleanup-job

Both jobs should be ENABLED.

---

## Verify Workflow Status

```bash
gcloud workflows list
```

Expected Workflows:

* cai-export-workflow
* cai-cleanup-workflow

---

## Verify BigQuery Inventory Dataset

```bash
bq ls governance_inventory
```

Expected:

Recent asset export tables should exist.

Example:

```text
asset_export_18_06_2026_103015
asset_export_18_06_2026_104015
asset_export_18_06_2026_105015
```

---

# Weekly Checks

## Verify Tag Structure

Run:

```bash
cd bootstrap/tags

./list-tags.sh
```

Verify:

### Tag Keys

* environment
* owner
* application

### Tag Values

Environment:

* dev
* test
* uat
* prod

Owner:

* platform-team
* cloud-team
* networking-team
* security-team

Application:

* payments
* crm
* analytics
* ecommerce

---

## Verify IAM Deny Policies

```bash
gcloud iam policies list \
  --attachment-point="cloudresourcemanager.googleapis.com/projects/<PROJECT_NUMBER>" \
  --kind=denypolicies
```

Expected:

* deny-vm-governance
* deny-disk-governance
* deny-snapshot-governance

---

# Monthly Checks

## Governance Review

Review:

* New applications
* New owner groups
* New environments

Determine whether additional Tag Values are required.

---

## Compliance Reporting

Review exported inventory data.

Validate:

* Labels present
* Tags present
* Resources correctly categorised

---

# Common Operational Tasks

## Add New Application

1. Update bootstrap tag values.
2. Deploy bootstrap.
3. Verify tag value creation.
4. Update customer configuration if required.

---

## Add New Owner

1. Update bootstrap tag values.
2. Apply bootstrap.
3. Verify tag value creation.

---

## Add New Workload

Update:

```text
terraform/environments/<env>/<env>.auto.tfvars
```

Example:

```hcl
workload_ids = [
  "01",
  "02",
  "03"
]
```

Run:

```bash
./terraform.sh apply
```

---

# Incident Response

## Missing Asset Exports

Check:

```bash
gcloud scheduler jobs describe cai-export-job
```

Then:

```bash
gcloud workflows executions list \
  --workflow=cai-export-workflow \
  --location=<REGION>
```

---

## Failed Governance Validation

Run:

```bash
./scripts/verify-all.sh
```

Review failed component.

---

## Missing Tags

Verify:

```bash
./list-tags.sh
```

Redeploy bootstrap if required.

---

# Escalation Matrix

## L1 Support

Responsible For:

* Monitoring
* Verification
* Reporting
* Initial Troubleshooting

---

## L2 Cloud Operations

Responsible For:

* Tag Management
* Policy Management
* IAM Deny Policies
* Workflow Failures

---

## Platform Engineering

Responsible For:

* Terraform Modules
* Architecture Changes
* New Governance Controls
* Accelerator Enhancements

---

# Success Criteria

The platform is healthy when:

* Governance policies are enabled
* IAM deny policies are enabled
* Asset exports are running
* BigQuery inventory is updating
* Tag hierarchy is available
* Compliance validation passes
