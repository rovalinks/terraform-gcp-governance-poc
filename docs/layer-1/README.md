# Layer 1 - Preventative Governance Controls Using Native GCP and Terraform

## Overview

Layer 1 demonstrates how governance requirements can be enforced proactively during resource provisioning.

The objective of this layer was to prevent the creation of non-compliant resources by implementing preventative controls using native Google Cloud capabilities and Terraform.

No custom applications, Cloud Run services, or bespoke code were required.

---

# Objectives

The objectives of Layer 1 were to:

* Enforce approved environment values.
* Automatically apply mandatory labels.
* Prevent creation of non-compliant resources.
* Validate governance controls for both Terraform and direct GCP users.
* Demonstrate cloud-native alternatives to custom governance applications.

---

# Architecture

Terraform Validation

↓

Terraform Mandatory Labels

↓

Custom Organization Policies

↓

IAM Deny Policies

↓

Compliant Resource Creation

---

# Scope

The following resource types were evaluated:

* Compute Engine Virtual Machines
* Compute Engine Persistent Disks
* Compute Engine Snapshots

Mandatory metadata standards:

| Label       | Purpose                |
| ----------- | ---------------------- |
| environment | Deployment environment |
| owner       | Resource owner         |
| application | Business application   |

---

# Environment

Organisation ID:

```text
321880981428
```

Project ID:

```text
project-a9c3b175-7f78-4ba6-9ad
```

Project Number:

```text
106228803995
```

Region:

```text
europe-west2
```

Zone:

```text
europe-west2-a
```

---

# Step 1 - Terraform Environment Validation

Terraform validations were implemented to ensure only approved environments could be deployed.

Approved values:

```text
dev
test
uat
prod
```

Implementation:

```hcl
validation {
  condition = contains(
    ["dev", "test", "uat", "prod"],
    lower(var.environment)
  )

  error_message = "Environment must be one of: dev, test, uat, prod."
}
```

---

# Validation Test

Invalid value:

```hcl
environment = "demo"
```

Terraform execution:

```bash
./terraform.sh plan
```

Expected Result:

```text
Environment must be one of: dev, test, uat, prod.
```

Outcome:

Prevented before deployment.

Status:

```text
VALIDATED
```

---

# Step 2 - Mandatory Labels in Terraform

Mandatory labels were automatically injected.

Implementation:

```hcl
locals {
  mandatory_labels = {
    environment = var.environment
    owner        = var.owner
    application  = var.application
  }
}
```

Applied to resources:

```hcl
labels = local.mandatory_labels
```

Example:

```yaml
labels:
  environment: dev
  owner: platform-team
  application: payments
```

Outcome:

Resources created through Terraform automatically complied.

Status:

```text
VALIDATED
```

---

# Step 3 - Terraform Plan Demonstration

Terraform plan demonstrated governance updates.

Command:

```bash
./terraform.sh plan
```

Example output:

```text
~ labels = {
    owner = "dev-team"
  }

→

~ labels = {
    owner = "platform-team"
  }
```

Outcome:

Governance changes became visible before deployment.

Status:

```text
VALIDATED
```

---

# Step 4 - Terraform Apply Demonstration

Deployment command:

```bash
./terraform.sh apply
```

Verification:

VM:

```bash
gcloud compute instances describe dev-tagging-vm-01 \
  --zone=europe-west2-a \
  --format="yaml(labels)"
```

Disk:

```bash
gcloud compute disks describe dev-tagging-disk-01 \
  --zone=europe-west2-a \
  --format="yaml(labels)"
```

Snapshot:

```bash
gcloud compute snapshots describe dev-tagging-snapshot-01 \
  --format="yaml(labels)"
```

Outcome:

Mandatory labels were successfully deployed.

Status:

```text
VALIDATED
```

---

# Step 5 - Custom Organization Policy Constraints

Custom constraints were created to prevent VM creation without labels.

Environment Constraint:

```yaml
name: organizations/321880981428/customConstraints/custom.requireEnvironmentLabels

resourceTypes:
- compute.googleapis.com/Instance

methodTypes:
- CREATE

condition: "!('environment' in resource.labels)"

actionType: DENY
```

Application Constraint:

```yaml
condition: "!('application' in resource.labels)"
```

Owner Constraint:

```yaml
condition: "!('owner' in resource.labels)"
```

Apply constraints:

```bash
gcloud org-policies set-custom-constraint \
org-policies/custom-constraints/environment-label.yaml

gcloud org-policies set-custom-constraint \
org-policies/custom-constraints/application-label.yaml

gcloud org-policies set-custom-constraint \
org-policies/custom-constraints/owner-label.yaml
```

Outcome:

Constraints successfully created.

Status:

```text
VALIDATED
```

---

# Step 6 - Enable Organization Policies

Environment Policy:

```bash
gcloud org-policies set-policy \
org-policies/policies/environment-policy.yaml
```

Application Policy:

```bash
gcloud org-policies set-policy \
org-policies/policies/application-policy.yaml
```

Owner Policy:

```bash
gcloud org-policies set-policy \
org-policies/policies/owner-policy.yaml
```

Outcome:

Policies enforced.

Status:

```text
VALIDATED
```

---

# Step 7 - Test VM Creation Without Labels

Command:

```bash
gcloud compute instances create vm-no-labels \
  --zone=europe-west2-a \
  --machine-type=e2-micro \
  --image-family=debian-12 \
  --image-project=debian-cloud
```

Expected Result:

```text
Operation denied by custom org policy.
```

Outcome:

VM creation blocked.

Status:

```text
VALIDATED
```

---

# Step 8 - Test VM Creation With Partial Labels

Command:

```bash
gcloud compute instances create vm-partial \
  --zone=europe-west2-a \
  --machine-type=e2-micro \
  --image-family=debian-12 \
  --image-project=debian-cloud \
  --labels=environment=dev
```

Expected Result:

```text
Operation denied by custom org policy.
```

Outcome:

VM creation blocked.

Status:

```text
VALIDATED
```

---

# Step 9 - Test VM Creation With Valid Labels

Command:

```bash
gcloud compute instances create vm-valid \
  --zone=europe-west2-a \
  --machine-type=e2-micro \
  --image-family=debian-12 \
  --image-project=debian-cloud \
  --labels=environment=dev,owner=platform-team,application=payments
```

Expected Result:

```text
Instance created successfully.
```

Outcome:

Compliant VM creation allowed.

Status:

```text
VALIDATED
```

---

# Step 10 - IAM Deny Policies

VM Deny Policy:

```yaml
deniedPermissions:
- compute.googleapis.com/instances.create
- compute.googleapis.com/instances.setLabels
- compute.googleapis.com/instances.createTagBinding
```

Disk Deny Policy:

```yaml
deniedPermissions:
- compute.googleapis.com/disks.create
- compute.googleapis.com/disks.setLabels
```

Snapshot Deny Policy:

```yaml
deniedPermissions:
- compute.googleapis.com/snapshots.create
- compute.googleapis.com/snapshots.setLabels
```

Apply policies:

```bash
gcloud iam policies create deny-vm-governance \
  --attachment-point=cloudresourcemanager.googleapis.com/projects/106228803995 \
  --kind=denypolicies \
  --policy-file=iam-deny/deny-vm-governance.yaml
```

```bash
gcloud iam policies create deny-disk-governance \
  --attachment-point=cloudresourcemanager.googleapis.com/projects/106228803995 \
  --kind=denypolicies \
  --policy-file=iam-deny/deny-disk-governance.yaml
```

```bash
gcloud iam policies create deny-snapshot-governance \
  --attachment-point=cloudresourcemanager.googleapis.com/projects/106228803995 \
  --kind=denypolicies \
  --policy-file=iam-deny/deny-snapshot-governance.yaml
```

Outcome:

Deny controls enforced.

Status:

```text
VALIDATED
```

---

# Step 11 - IAM Deny Validation

Attempt:

```bash
gcloud compute instances create deny-test \
  --zone=europe-west2-a
```

Expected Result:

```text
PERMISSION_DENIED
```

Outcome:

Resource creation blocked.

Status:

```text
VALIDATED
```

---

# Layer 1 Test Results

| Test Scenario                     | Expected Result | Actual Result | Status |
| --------------------------------- | --------------- | ------------- | ------ |
| Invalid Terraform environment     | Blocked         | Blocked       | ✅      |
| Terraform mandatory labels        | Applied         | Applied       | ✅      |
| Terraform plan governance updates | Visible         | Visible       | ✅      |
| VM without labels                 | Denied          | Denied        | ✅      |
| VM with partial labels            | Denied          | Denied        | ✅      |
| VM with valid labels              | Allowed         | Allowed       | ✅      |
| IAM deny VM create                | Denied          | Denied        | ✅      |
| IAM deny Disk create              | Denied          | Denied        | ✅      |
| IAM deny Snapshot create          | Denied          | Denied        | ✅      |

---

# Layer 1 Findings

## Terraform Controls

Status:

```text
SUPPORTED
```

Effective for Infrastructure-as-Code deployments.

---

## Custom Organization Policies

Status:

```text
PARTIALLY SUPPORTED
```

Validated for:

```text
Compute Engine Virtual Machines
```

Not supported during this PoC for:

```text
Persistent Disks
Snapshots
```

---

## IAM Deny Policies

Status:

```text
SUPPORTED
```

Effective as a preventative control.

---

# Layer 1 Outcome

Layer 1 successfully demonstrated that preventative governance controls can be implemented using native GCP capabilities and Terraform.

The following governance workflow was validated:

Validate

↓

Enforce

↓

Prevent

↓

Allow Compliant Resources

This approach eliminates the need for custom governance applications while providing strong preventative controls.

---

# Conclusion

Layer 1 proved that enterprise governance requirements can be enforced before resources are deployed by combining Terraform validations, automatic label injection, Custom Organization Policies, and IAM Deny Policies.

These native capabilities provide scalable and maintainable preventative controls aligned with cloud-native governance best practices without introducing custom applications or operational overhead.

