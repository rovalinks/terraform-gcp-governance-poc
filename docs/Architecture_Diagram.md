# GCP Governance Accelerator - Architecture

```mermaid
flowchart TB

    Customer[Customer Configuration]

    Customer --> Config[config/customer.auto.tfvars]

    Config --> Bootstrap[Bootstrap Deployment]

    Bootstrap --> Tags[Resource Manager Tags]
    Bootstrap --> TagValues[Tag Values]

    Config --> Terraform[Terraform Governance Deployment]

    Terraform --> Compute[Compute Instances]
    Terraform --> Disks[Persistent Disks]
    Terraform --> Snapshots[Snapshots]
    Terraform --> BigQuery[BigQuery Governance Dataset]

    Tags --> TagBindings[Tag Bindings]
    TagValues --> TagBindings

    TagBindings --> Compute
    TagBindings --> Disks
    TagBindings --> Snapshots

    Config --> Policies[Organisation Policies]

    Policies --> EnvironmentPolicy[Environment Label Policy]
    Policies --> ApplicationPolicy[Application Label Policy]
    Policies --> OwnerPolicy[Owner Label Policy]

    Config --> DenyPolicies[IAM Deny Policies]

    DenyPolicies --> VMDeny[VM Governance]
    DenyPolicies --> DiskDeny[Disk Governance]
    DenyPolicies --> SnapshotDeny[Snapshot Governance]
    DenyPolicies --> TagDeny[Tag Governance]

    AssetInventory[Cloud Asset Inventory]

    Compute --> AssetInventory
    Disks --> AssetInventory
    Snapshots --> AssetInventory

    AssetInventory --> Workflow[Cloud Workflow]

    Workflow --> Export[Asset Export]

    Export --> BigQuery

    Scheduler[Cloud Scheduler]

    Scheduler --> Workflow

    Verify[Verification Scripts]

    Verify --> Policies
    Verify --> DenyPolicies
    Verify --> BigQuery

```

## Governance Layers

### Layer 1 - Preventive Controls

* Organisation Policies
* Custom Constraints
* Mandatory Labels

### Layer 2 - Enforcement Controls

* IAM Deny Policies
* Resource Manager Tags
* Tag Bindings

### Layer 3 - Detective Controls

* Cloud Asset Inventory
* BigQuery Governance Dataset
* Automated Asset Export

## Deployment Flow

1. Update customer.auto.tfvars
2. Generate environment configuration
3. Deploy bootstrap resources
4. Deploy Terraform governance resources
5. Enable governance controls
6. Verify controls
7. Monitor compliance through Asset Inventory exports

## Key Components

### Resource Manager Tags

Provides governance metadata across resources.

### Organisation Policies

Prevents creation of resources without required labels.

### IAM Deny Policies

Prevents modification or removal of governance controls.

### Cloud Asset Inventory

Exports resource inventory for compliance reporting.

### BigQuery

Stores governance inventory for reporting and analytics.
