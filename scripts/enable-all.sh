#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/config.sh"

echo "======================================"
echo "Enabling Governance Controls"
echo "======================================"

echo ""
echo "======================================"
echo "Updating Custom Constraints"
echo "======================================"

gcloud org-policies set-custom-constraint \
    org-policies/generated/custom-constraints/environment-label.yaml

gcloud org-policies set-custom-constraint \
    org-policies/generated/custom-constraints/application-label.yaml

gcloud org-policies set-custom-constraint \
    org-policies/generated/custom-constraints/owner-label.yaml

echo ""
echo "======================================"
echo "Updating Org Policies"
echo "======================================"

gcloud org-policies set-policy \
    org-policies/generated/policies/environment-policy.yaml

gcloud org-policies set-policy \
    org-policies/generated/policies/application-policy.yaml

gcloud org-policies set-policy \
    org-policies/generated/policies/owner-policy.yaml

echo ""
echo "======================================"
echo "Ensuring IAM Deny Policies Exist"
echo "======================================"

POLICIES=$(gcloud iam policies list \
    --attachment-point="cloudresourcemanager.googleapis.com/projects/${PROJECT_NUMBER}" \
    --kind=denypolicies \
    --format="value(name)" 2>/dev/null || true)

create_deny_policy() {
    local POLICY_ID=$1
    local POLICY_FILE=$2

    if echo "${POLICIES}" | grep -Fq "/${POLICY_ID}"; then
        echo "✓ ${POLICY_ID} already exists. Skipping."
    else
        gcloud iam policies create "${POLICY_ID}" \
            --attachment-point="cloudresourcemanager.googleapis.com/projects/${PROJECT_NUMBER}" \
            --kind=denypolicies \
            --policy-file="${POLICY_FILE}"

        echo "✓ ${POLICY_ID} created."
    fi
}

create_deny_policy \
    "deny-vm-governance" \
    "iam-deny/deny-vm-governance.yaml"

create_deny_policy \
    "deny-disk-governance" \
    "iam-deny/deny-disk-governance.yaml"

create_deny_policy \
    "deny-snapshot-governance" \
    "iam-deny/deny-snapshot-governance.yaml"

echo ""
echo "======================================"
echo "Governance Controls Enabled"
echo "======================================"

echo ""
echo "Enabled Controls:"
echo "  ✓ Custom Constraints"
echo "      - requireEnvironmentLabels"
echo "      - requireApplicationLabels"
echo "      - requireOwnerLabels"

echo ""
echo "  ✓ Org Policies"
echo "      - custom.requireEnvironmentLabels"
echo "      - custom.requireApplicationLabels"
echo "      - custom.requireOwnerLabel1"

echo ""
echo "  ✓ IAM Deny Policies"
echo "      - deny-vm-governance"
echo "      - deny-disk-governance"
echo "      - deny-snapshot-governance"

echo ""
echo "Verify using:"
echo "    ./scripts/verify-all.sh"

echo ""
