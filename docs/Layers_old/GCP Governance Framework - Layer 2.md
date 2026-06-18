# GCP Governance Framework - Layer 2 Proof of Concept

## Brownfield Detection Using Cloud Asset Inventory and BigQuery

---

# Document Control

 Item            Value                                  
 --------------  -------------------------------------- 
 Document Title  GCP Governance Framework - Layer 2 PoC 
 Version         1.0                                    
 Prepared For    Customer Review                        
 Prepared By     Cloud & Platform Engineering           
 PoC Scope       Layer 2 - Brownfield Detection         
 Status          Completed                              
 Outcome         Successfully Validated                 

---

# Executive Summary

Layer 2 demonstrates how existing brownfield resources can be detected using native Google Cloud services without requiring custom applications, Cloud Run services, or bespoke code.

The implementation exports Cloud Asset Inventory metadata into BigQuery and uses standard SQL queries to identify resources that do not comply with mandatory governance requirements.

The PoC successfully validated detection of

 Terraform-managed resources
 Legacy Compute Engine resources
 Persistent Disks
 Compute Snapshots
 BigQuery Datasets

All Layer 2 validation scenarios passed successfully.

---

# Objectives

The objectives of Layer 2 were to

 Detect non-compliant brownfield resources.
 Export resource metadata using Cloud Asset Inventory.
 Store inventory snapshots within BigQuery.
 Identify missing governance labels using SQL.
 Demonstrate cloud-native alternatives to custom detection applications.
 Produce consolidated compliance reporting.

---

# Architecture

Cloud Asset Inventory

↓

BigQuery Export

↓

BigQuery SQL

↓

Brownfield Detection

↓

Compliance Reporting

---

# Services Used

 Service                Purpose                        
 ---------------------  ------------------------------ 
 Cloud Asset Inventory  Export resource metadata       
 BigQuery               Store exported assets          
 BigQuery SQL           Detect non-compliant resources 
 gcloud CLI             Execute exports                
 bq CLI                 Query exported data            

No Cloud Run services or custom applications were required.

---

# Scope

The following resource types were evaluated

 Compute Engine Virtual Machines
 Persistent Disks
 Compute Snapshots
 BigQuery Datasets

Mandatory governance attributes

 Attribute    Purpose                
 -----------  ---------------------- 
 environment  Deployment environment 
 owner        Resource ownership     
 application  Business application   

---

# Environment Details

 Item             Value                          
 ---------------  ------------------------------ 
 Organisation ID  321880981428                   
 Project ID       project-a9c3b175-7f78-4ba6-9ad 
 Project Number   106228803995                   
 Region           europe-west2                   
 Dataset          governance_inventory_dev       

---

# APIs Enabled

Command

```bash
gcloud services enable 
    cloudasset.googleapis.com 
    bigquery.googleapis.com
```

Outcome

Required services successfully enabled.

Status

VALIDATED

---

# Layer 2 Controls

## Control 1 - Governance Inventory Dataset Creation

### Objective

Create a dedicated BigQuery dataset for governance reporting.

Command

```bash
PROJECT_ID=$(gcloud config get-value project)

DATASET_NAME=governance_inventory_dev

bq mk 
    --location=europe-west2 
    $DATASET_NAME

bq ls --project_id=$PROJECT_ID
```

Expected Result

Dataset created successfully.

Actual Result

```text
Dataset 'project-a9c3b175-7f78-4ba6-9adgovernance_inventory_dev' successfully created.
```

Outcome

Governance dataset provisioned.

Status

VALIDATED

---

## Control 2 - Cloud Asset Inventory Export

### Objective

Export project assets into BigQuery.

Command

```bash
gcloud asset export 
    --project=$PROJECT_ID 
    --content-type=resource 
    --asset-types=compute.googleapis.comInstance,compute.googleapis.comDisk,compute.googleapis.comSnapshot,bigquery.googleapis.comDataset 
    --bigquery-table=projects$PROJECT_IDdatasets$DATASET_NAMEtablesasset_export 
    --output-bigquery-force
```

Outcome

Export completed successfully.

Export Operation

```text
projects106228803995operationsExportAssetsRESOURCEf52a8f08e84acd26295e4bd23e9c93f8
```

Read Time

```text
2026-06-16T185653.586690624Z
```

Status

VALIDATED

---

## Control 3 - BigQuery Export Validation

### Objective

Verify exported resources loaded successfully.

Command

```sql
SELECT COUNT() total
FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory_dev.asset_export`
```

Expected Result

Rows returned.

Actual Result

```text
17 resources exported.
```

Outcome

Export data successfully loaded.

Status

VALIDATED

---

## Control 4 - Terraform-Managed VM Compliance

### Objective

Validate compliant Terraform resources are not detected.

Query

```sql
SELECT
    name
FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory_dev.asset_export`
WHERE asset_type='compute.googleapis.comInstance'
AND name LIKE '%dev-payments-vm%'
AND (
      JSON_VALUE(resource.data,'$.labels.environment') IS NULL
   OR JSON_VALUE(resource.data,'$.labels.owner') IS NULL
   OR JSON_VALUE(resource.data,'$.labels.application') IS NULL
)
```

Expected Result

Zero rows returned.

Actual Result

Zero rows returned.

Outcome

Terraform-managed resources remained compliant.

Status

VALIDATED

---

## Control 5 - Legacy VM Detection

### Objective

Detect unmanaged Compute Engine instances.

Test Resource

```text
legacy-vm
```

Query

```sql
SELECT
    name,
    asset_type
FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory.asset_export`
WHERE asset_type='compute.googleapis.comInstance'
AND name LIKE '%legacy-vm%'
AND (
      JSON_VALUE(resource.data,'$.labels.environment') IS NULL
   OR JSON_VALUE(resource.data,'$.labels.owner') IS NULL
   OR JSON_VALUE(resource.data,'$.labels.application') IS NULL
)
```

Expected Result

legacy-vm returned.

Actual Result

legacy-vm returned.

Outcome

Brownfield VM successfully detected.

Status

VALIDATED

---

## Control 6 - Persistent Disk Detection

### Objective

Detect non-compliant disks.

Query

```sql
SELECT
    name,
    asset_type
FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory_dev.asset_export`
WHERE asset_type='compute.googleapis.comDisk'
AND (
      JSON_VALUE(resource.data,'$.labels.environment') IS NULL
   OR JSON_VALUE(resource.data,'$.labels.owner') IS NULL
   OR JSON_VALUE(resource.data,'$.labels.application') IS NULL
)
```

Expected Result

Non-compliant disks returned.

Actual Result

Non-compliant disks returned.

Outcome

Brownfield disks successfully detected.

Status

VALIDATED

---

## Control 7 - Snapshot Compliance Validation

### Objective

Validate snapshots remained compliant.

Query

```sql
SELECT
    name
FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory_dev.asset_export`
WHERE asset_type='compute.googleapis.comSnapshot'
AND (
      JSON_VALUE(resource.data,'$.labels.environment') IS NULL
   OR JSON_VALUE(resource.data,'$.labels.owner') IS NULL
   OR JSON_VALUE(resource.data,'$.labels.application') IS NULL
)
```

Expected Result

No rows returned.

Actual Result

No rows returned.

Outcome

Snapshots remained compliant.

Status

VALIDATED

---

## Control 8 - BigQuery Dataset Detection

### Objective

Detect datasets missing governance labels.

Test Resource

```text
governance_inventory2
```

Query

```sql
SELECT
    name,
    asset_type
FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory_dev.asset_export`
WHERE asset_type='bigquery.googleapis.comDataset'
AND (
      JSON_VALUE(resource.data,'$.labels.environment') IS NULL
   OR JSON_VALUE(resource.data,'$.labels.owner') IS NULL
   OR JSON_VALUE(resource.data,'$.labels.application') IS NULL
)
```

Expected Result

governance_inventory2 returned.

Actual Result

governance_inventory2 returned.

Outcome

Brownfield BigQuery datasets successfully detected.

Status

VALIDATED

---

## Control 9 - Consolidated Compliance Report

### Objective

Produce a single report of all non-compliant resources.

Query

```sql
SELECT
    asset_type,
    name
FROM `project-a9c3b175-7f78-4ba6-9ad.governance_inventory_dev.asset_export`
WHERE
      JSON_VALUE(resource.data,'$.labels.environment') IS NULL
   OR JSON_VALUE(resource.data,'$.labels.owner') IS NULL
   OR JSON_VALUE(resource.data,'$.labels.application') IS NULL
ORDER BY asset_type,name;
```

Expected Result

Only non-compliant resources listed.

Actual Result

Only brownfield resources listed.

Outcome

Consolidated compliance reporting achieved.

Status

VALIDATED

---

# Layer 2 Test Results

 Test Scenario                      Expected Result     Actual Result       Status 
 ---------------------------------  ------------------  ------------------  ------ 
 Governance dataset creation        Successful          Successful          ✅      
 Cloud Asset export execution       Successful          Successful          ✅      
 BigQuery export validation         Rows returned       17 rows returned    ✅      
 Terraform-managed VM compliance    No findings         No findings         ✅      
 Legacy VM detection                Detected            Detected            ✅      
 Persistent Disk detection          Detected            Detected            ✅      
 Snapshot compliance validation     No findings         No findings         ✅      
 BigQuery Dataset detection         Detected            Detected            ✅      
 Consolidated compliance reporting  Findings generated  Findings generated  ✅      

---

# Findings

## Cloud Asset Inventory

Status

```text
SUPPORTED
```

Successfully exported project assets into BigQuery.

---

## Brownfield Detection

Status

```text
SUPPORTED
```

Successfully detected unmanaged resources.

---

## Terraform Resource Validation

Status

```text
SUPPORTED
```

Compliant Terraform-managed resources were excluded from findings.

---

## BigQuery Compliance Reporting

Status

```text
SUPPORTED
```

Standard SQL provided consolidated compliance reporting without custom code.

---

## Organisation-Level Export

Status

```text
NOT VALIDATED
```

Organisation-wide exports using `--per-asset-type` were not validated during this PoC.

---

# Layer 2 Outcome

Layer 2 successfully demonstrated that brownfield resources can be detected using fully managed Google Cloud services and standard tooling.

The following detection lifecycle was validated

Export

↓

Store

↓

Query

↓

Detect

↓

Report

No custom applications, Cloud Run services, or bespoke detection components were required.

---

# Customer Sign-Off

 Item                           Status   
 -----------------------------  -------- 
 Cloud Asset Inventory Export   Accepted 
 BigQuery Inventory             Accepted 
 Brownfield Detection           Accepted 
 Terraform Resource Validation  Accepted 
 BigQuery Dataset Detection     Accepted 
 Consolidated Reporting         Accepted 
 Layer 2 Overall Outcome        Accepted 

Customer Representative

---

Date

---

Signature

---

---

# Conclusion

Layer 2 proved that enterprise brownfield governance detection can be implemented using native Google Cloud services, Cloud Asset Inventory, BigQuery, and SQL.

The approach provides scalable and maintainable detection capabilities aligned with cloud-native governance best practices while eliminating the need for bespoke applications or operational overhead.
