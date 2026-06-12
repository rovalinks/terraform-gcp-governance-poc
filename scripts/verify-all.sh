#!/bin/bash

source "$(dirname "$0")/config.sh"

echo "======================================"
echo "Custom Constraints"
echo "======================================"

gcloud org-policies list-custom-constraints \
    --organization="${ORG_ID}"

echo ""
echo "======================================"
echo "Org Policies"
echo "======================================"

gcloud org-policies list \
    --organization="${ORG_ID}"

echo ""
echo "======================================"
echo "IAM Deny Policies"
echo "======================================"

gcloud iam policies list \
    --attachment-point="cloudresourcemanager.googleapis.com/projects/${PROJECT_NUMBER}" \
    --kind=denypolicies
