  Test              | Expected          | Actual            | Result |
| ----------------- | ----------------- | ----------------- | ------ |
| VM without labels | Denied            | Denied            | ✅      |
| VM partial labels | Denied            | Denied            | ✅      |
| VM valid labels   | Created           | Created           | ✅      |
| Disk Org Policy   | Unsupported       | Unsupported       | ✅      |
| IAM Deny          | Permission denied | Permission denied | ✅      |


## Resource Manager Tag Binding Findings

- Resource Manager Tags were successfully attached to Compute Engine VMs using gcloud.
- Tag visibility was verified in the GCP Console.
- Terraform automation using:
  - google_tags_tag_binding
  - google_tags_location_tag_binding
  could not be completed due to provider behaviour inconsistencies observed with Google Provider v6.50.0.
- The PoC successfully demonstrated the capability using native GCP tooling without custom applications.

