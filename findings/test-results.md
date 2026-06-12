  Test              | Expected          | Actual            | Result |
| ----------------- | ----------------- | ----------------- | ------ |
| VM without labels | Denied            | Denied            | ✅      |
| VM partial labels | Denied            | Denied            | ✅      |
| VM valid labels   | Created           | Created           | ✅      |
| Disk Org Policy   | Unsupported       | Unsupported       | ✅      |
| IAM Deny          | Permission denied | Permission denied | ✅      |

