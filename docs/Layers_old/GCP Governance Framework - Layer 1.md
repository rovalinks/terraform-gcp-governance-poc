# GCP Governance Framework - Layer 1 Proof of Concept

## Preventative Governance Controls Using Native GCP and Terraform

---

# Document Control

 Item            Value                                  
 --------------  -------------------------------------- 
 Document Title  GCP Governance Framework - Layer 1 PoC 
 Version         1.0                                    
 Prepared For    Customer Review                        
 Prepared By     Cloud & Platform Engineering           
 PoC Scope       Layer 1 - Preventative Controls        
 Status          Completed                              
 Outcome         Successfully Validated                 

---

# Executive Summary

This Proof of Concept demonstrates how enterprise governance requirements can be implemented using native Google Cloud capabilities and Terraform without introducing custom applications, Cloud Run services, or bespoke code.

The objective of Layer 1 was to proactively prevent the creation and modification of non-compliant resources through preventative controls.

The PoC successfully validated

 Terraform environment validation
 Automatic mandatory label injection
 Resource Manager Tags
 Custom Organization Policies
 IAM Deny Policies
 Governance protection mechanisms

All Layer 1 validation scenarios passed successfully.

---

# Objectives

The objectives of Layer 1 were to

 Enforce approved deployment environments.
 Automatically apply mandatory governance labels.
 Implement centrally governed Resource Manager Tags.
 Prevent creation of non-compliant resources.
 Protect governance metadata from unauthorised changes.
 Demonstrate cloud-native alternatives to custom governance applications.

---

# Architecture

Terraform Validation

↓

Mandatory Labels

↓

Resource Manager Tags

↓

Custom Organization Policies

↓

IAM Deny Policies

↓

Compliant Resource Creation

↓

Governance Metadata Protection

---

# Scope

The following resource types were evaluated

 Compute Engine Virtual Machines
 Compute Engine Persistent Disks
 Compute Engine Snapshots

Mandatory governance attributes

 Attribute    Purpose                
 -----------  ---------------------- 
 environment  Deployment environment 
 owner        Resource ownership     
 application  Business application   

Approved environment values

```text
dev
test
uat
prod
```

---

# Environment Details

 Item             Value                          
 ---------------  ------------------------------ 
 Organisation ID  321880981428                   
 Project ID       project-a9c3b175-7f78-4ba6-9ad 
 Project Number   106228803995                   
 Region           europe-west2                   
 Zone             europe-west2-a                 

---

# Layer 1 Controls

## Control 1 - Terraform Environment Validation

### Objective

Prevent invalid deployment environments.

### Implementation

```hcl
validation {
  condition = contains(
    [dev, test, uat, prod],
    lower(var.environment)
  )

  error_message = Environment must be one of dev, test, uat, prod.
}
```

### Validation Scenario

Invalid value

```hcl
environment = demo
```

Command

```bash
.terraform.sh plan
```

Expected Result

```text
Environment must be one of dev, test, uat, prod.
```

Actual Result

```text
Environment must be one of dev, test, uat, prod.
```

Outcome

Invalid deployments prevented before provisioning.

Status

```text
VALIDATED
```

---

## Control 2 - Mandatory Labels

### Objective

Automatically inject governance labels into Terraform-managed resources.

### Implementation

```hcl
locals {
  mandatory_labels = {
    environment = var.environment
    owner        = var.owner
    application  = var.application
  }
}
```

Applied using

```hcl
labels = local.mandatory_labels
```

Example

```yaml
labels
  environment dev
  owner platform-team
  application payments
```

Outcome

Terraform resources automatically complied with governance standards.

Status

```text
VALIDATED
```

---

## Control 3 - Terraform Plan Visibility

### Objective

Expose governance changes before deployment.

Command

```bash
.terraform.sh plan
```

Example

```text
~ labels = {
    owner = dev-team
  }

→

~ labels = {
    owner = platform-team
  }
```

Outcome

Governance updates became visible prior to deployment.

Status

```text
VALIDATED
```

---

## Control 4 - Terraform Apply Validation

### Objective

Verify successful deployment of mandatory labels.

Command

```bash
.terraform.sh apply
```

Verification

VM

```bash
gcloud compute instances describe dev-payments-vm-01 
  --zone=europe-west2-a 
  --format=yaml(labels)
```

Disk

```bash
gcloud compute disks describe dev-payments-disk-01 
  --zone=europe-west2-a 
  --format=yaml(labels)
```

Snapshot

```bash
gcloud compute snapshots describe dev-payments-snapshot-01 
  --format=yaml(labels)
```

Expected Labels

```yaml
environment dev
owner platform-team
application payments
```

Outcome

Mandatory labels successfully deployed.

Status

```text
VALIDATED
```

---

# Resource Manager Tags

## Objective

Apply centrally governed tags across supported resources.

### Tag Keys

 environment
 owner
 application

### Environment Values

```text
dev
test
uat
prod
```

### Owner Values

```text
platform-team
cloud-team
security-team
networking-team
```

### Application Values

```text
payments
ecommerce
crm
analytics
```

---

## Tag Keys Validation

Command

```bash
gcloud resource-manager tags keys list
```

Outcome

Tag keys successfully created.

Status

```text
VALIDATED
```

---

## Approved Tag Values Validation

Command

```bash
gcloud resource-manager tags values list 
  --parent=TAG_KEY
```

Outcome

Approved values successfully validated.

Status

```text
VALIDATED
```

---

## VM Tag Validation

Verification

```bash
gcloud resource-manager tags bindings list 
  --parent=compute.googleapis.comprojects106228803995zoneseurope-west2-ainstancesINSTANCE_ID 
  --location=europe-west2-a
```

Outcome

VM tags successfully attached.

Status

```text
VALIDATED
```

---

## Disk Tag Validation

Verification

```bash
gcloud resource-manager tags bindings list 
  --parent=compute.googleapis.comprojects106228803995zoneseurope-west2-adisksDISK_ID 
  --location=europe-west2-a
```

Outcome

Disk tags successfully attached.

Status

```text
VALIDATED
```

---

## Snapshot Tag Validation

Verification

```bash
gcloud resource-manager tags bindings list 
  --parent=compute.googleapis.comprojects106228803995globalsnapshotsSNAPSHOT_ID
```

Outcome

Snapshot tags successfully attached.

Status

```text
VALIDATED
```

---

# Custom Organization Policies

## Objective

Prevent creation of non-compliant Compute Engine instances.

### Environment Constraint

```yaml
condition !('environment' in resource.labels)
```

### Owner Constraint

```yaml
condition !('owner' in resource.labels)
```

### Application Constraint

```yaml
condition !('application' in resource.labels)
```

Resource Type

```text
compute.googleapis.comInstance
```

Method

```text
CREATE
```

Outcome

Constraints successfully implemented.

Status

```text
VALIDATED
```

---

## VM Without Labels

Command

```bash
gcloud compute instances create vm-no-labels 
  --zone=europe-west2-a 
  --machine-type=e2-micro 
  --image-family=debian-12 
  --image-project=debian-cloud
```

Expected Result

```text
Operation denied by custom org policy.
```

Actual Result

```text
Operation denied by custom org policy.
```

Status

```text
VALIDATED
```

---

## VM With Partial Labels

Command

```bash
gcloud compute instances create vm-partial 
  --zone=europe-west2-a 
  --machine-type=e2-micro 
  --image-family=debian-12 
  --image-project=debian-cloud 
  --labels=environment=dev
```

Expected Result

```text
Operation denied by custom org policy.
```

Actual Result

```text
Operation denied by custom org policy.
```

Status

```text
VALIDATED
```

---

## VM With Valid Labels

Command

```bash
gcloud compute instances create vm-valid 
  --zone=europe-west2-a 
  --machine-type=e2-micro 
  --image-family=debian-12 
  --image-project=debian-cloud 
  --labels=environment=dev,owner=platform-team,application=payments
```

Expected Result

```text
Instance created successfully.
```

Actual Result

```text
Instance created successfully.
```

Status

```text
VALIDATED
```

---

# IAM Deny Policies

## Objective

Protect governance metadata after deployment.

Validated deny scenarios

 VM governance modifications
 Disk governance modifications
 Snapshot governance modifications
 Governance tag removal

Outcome

Preventative controls remained effective after deployment.

Status

```text
VALIDATED
```

---

## IAM Deny Validation

Validation command examples

```bash
gcloud compute instances add-labels dev-payments-vm-01 
  --zone=europe-west2-a 
  --labels=owner=test
```

```bash
gcloud compute disks add-labels dev-payments-disk-01 
  --zone=europe-west2-a 
  --labels=owner=test
```

```bash
gcloud compute snapshots add-labels dev-payments-snapshot-01 
  --labels=owner=test
```

```bash
gcloud resource-manager tags bindings delete TAG_BINDING_NAME
```

Expected Result

```text
PERMISSION_DENIED
```

Actual Result

```text
PERMISSION_DENIED
```

Status

```text
VALIDATED
```

---

# Layer 1 Test Results

 Test Scenario                           Expected Result  Actual Result  Status 
 --------------------------------------  ---------------  -------------  ------ 
 Invalid Terraform environment           Blocked          Blocked        ✅      
 Mandatory labels automatically applied  Applied          Applied        ✅      
 Terraform plan visibility               Visible          Visible        ✅      
 Terraform apply validation              Successful       Successful     ✅      
 Tag keys validation                     Available        Available      ✅      
 Tag values validation                   Available        Available      ✅      
 VM tags attached                        Attached         Attached       ✅      
 Disk tags attached                      Attached         Attached       ✅      
 Snapshot tags attached                  Attached         Attached       ✅      
 VM without labels                       Denied           Denied         ✅      
 VM with partial labels                  Denied           Denied         ✅      
 VM with valid labels                    Allowed          Allowed        ✅      
 IAM deny protections                    Enforced         Enforced       ✅      
 VM governance modification              Denied           Denied         ✅      
 Disk governance modification            Denied           Denied         ✅      
 Snapshot governance modification        Denied           Denied         ✅      
 Governance tag removal                  Denied           Denied         ✅      

---

# Findings

## Terraform Controls

Status

```text
SUPPORTED
```

Effective for Infrastructure-as-Code deployments.

---

## Resource Manager Tags

Status

```text
SUPPORTED
```

Validated for

 Compute Instances
 Persistent Disks
 Snapshots

---

## Custom Organization Policies

Status

```text
PARTIALLY SUPPORTED
```

Validated for

```text
Compute Engine Instances
```

Not validated during this PoC for

```text
Persistent Disks
Snapshots
```

---

## IAM Deny Policies

Status

```text
SUPPORTED
```

Effective for protecting governance metadata post-deployment.

---

# Layer 1 Outcome

Layer 1 successfully demonstrated that preventative governance controls can be implemented using native Google Cloud capabilities and Terraform without introducing custom applications.

The following governance lifecycle was validated

Validate

↓

Enforce

↓

Prevent

↓

Protect

↓

Allow Compliant Resources

---

# Customer Sign-Off

 Item                     Status   
 -----------------------  -------- 
 Terraform Controls       Accepted 
 Mandatory Labels         Accepted 
 Resource Manager Tags    Accepted 
 Organization Policies    Accepted 
 IAM Deny Policies        Accepted 
 Layer 1 Overall Outcome  Accepted 

Customer Representative

---

Date

---

Signature

---

---

# Conclusion

Layer 1 proved that enterprise governance requirements can be enforced before and after resource deployment by combining Terraform validations, mandatory labels, Resource Manager Tags, Custom Organization Policies, and IAM Deny Policies.

The PoC demonstrated that native Google Cloud services provide scalable, maintainable, and enterprise-ready preventative governance controls without the need for bespoke governance applications or additional operational overhead.
