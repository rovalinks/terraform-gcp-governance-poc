# GCP Governance Accelerator - Customer Walkthrough

## Objective

Demonstrate how governance controls are enforced using native GCP capabilities without custom application code.

Estimated Duration: 30-45 minutes

---

# Agenda

1. Business Problem
2. Solution Architecture
3. Bootstrap Deployment
4. Governance Controls
5. Compliance Reporting
6. Operational Model
7. Questions

---

# 1. Business Problem

Most organisations struggle with:

* Missing labels
* Inconsistent tagging
* Poor ownership visibility
* Uncontrolled resource creation
* Lack of governance reporting

This accelerator addresses those challenges using native GCP services.

---

# 2. Architecture Overview

The solution consists of three governance layers.

## Layer 1 - Preventive Controls

Organisation Policies prevent deployment of non-compliant resources.

Examples:

* Missing Environment Label
* Missing Owner Label
* Missing Application Label

---

## Layer 2 - Enforcement Controls

IAM Deny Policies prevent removal or modification of governance controls.

Examples:

* Prevent Tag Removal
* Prevent Governance Label Changes
* Protect Compliance Resources

---

## Layer 3 - Detective Controls

Cloud Asset Inventory exports governance data into BigQuery.

This enables:

* Compliance Reporting
* Inventory Analysis
* Governance Dashboards

---

# 3. Bootstrap Demonstration

Show:

```bash
cd bootstrap/tags

terraform apply
```

Explain:

* Tag Keys
* Tag Values
* Organisation-wide governance taxonomy

Example:

```text
environment
owner
application
```

---

# 4. Governance Deployment Demonstration

Show:

```bash
./terraform.sh plan

./terraform.sh apply
```

Explain:

* Terraform deployment
* Automatic tag binding
* Governance metadata assignment

---

# 5. Preventive Control Demonstration

Attempt to create a resource without required labels.

Expected outcome:

```text
Denied by Organisation Policy
```

Explain:

Organisation Policies prevent non-compliant resources from being created.

---

# 6. Enforcement Control Demonstration

Attempt to remove governance tags.

Expected outcome:

```text
Denied by IAM Deny Policy
```

Explain:

Governance controls cannot be bypassed by standard users.

---

# 7. Compliance Reporting Demonstration

Show:

```bash
cd asset-export

./deploy.sh
```

Explain:

* Cloud Asset Inventory
* Scheduled exports
* BigQuery governance inventory

Show exported assets in BigQuery.

---

# 8. Operational Model

Customer responsibilities:

* Maintain tag taxonomy
* Manage governance policies
* Review compliance reports

Platform responsibilities:

* Deploy accelerator
* Update governance controls
* Maintain Terraform modules

---

# Key Benefits

## Native GCP Services

No custom applications.

## Reusable Architecture

Deployable across multiple projects and organisations.

## Automated Governance

Minimal operational overhead.

## Compliance Visibility

Centralised inventory and reporting.

---

# Closing Summary

The accelerator provides:

* Preventive Governance
* Enforcement Governance
* Detective Governance

using native Google Cloud services and Terraform-based automation.

Questions and discussion.
