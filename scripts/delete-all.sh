#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/config.sh"

echo "======================================"
echo "Deleting All Governance Artefacts"
echo "======================================"

echo ""
echo "======================================"
echo "Deleting IAM Deny Policies"
echo "======================================"

delete_deny_policy() {
    POLICY_ID=$1

    echo "Deleting ${POLICY_ID}..."

    gcloud iam policies delete "${POLICY_ID}" \
        --attachment-point="cloudresourcemanager.googleapis.com/projects/${PROJECT_NUMBER}" \
        --kind=denypolicies \
        >/dev/null 2>&1 \
        && echo "✓ ${POLICY_ID} deleted." \
        || echo "✓ ${POLICY_ID} not found. Skipping."
}

delete_deny_policy "deny-vm-governance"
delete_deny_policy "deny-disk-governance"
delete_deny_policy "deny-snapshot-governance"

echo ""
echo "======================================"
echo "Deleting Org Policies"
echo "======================================"

delete_org_policy() {
    POLICY_NAME=$1

    echo "Deleting ${POLICY_NAME}..."

    gcloud org-policies delete "${POLICY_NAME}" \
        --organization="${ORG_ID}" \
        >/dev/null 2>&1 \
        && echo "✓ ${POLICY_NAME} deleted." \
        || echo "✓ ${POLICY_NAME} not found. Skipping."
}

delete_org_policy "custom.requireEnvironmentLabel1"
delete_org_policy "custom.requireApplicationLabel1"
delete_org_policy "custom.requireOwnerLabel1"

echo ""
echo "======================================"
echo "Deleting Custom Constraints"
echo "======================================"

delete_constraint() {
    CONSTRAINT_NAME=$1

    echo "Deleting ${CONSTRAINT_NAME}..."

    gcloud org-policies delete-custom-constraint \
        "${CONSTRAINT_NAME}" \
        --organization="${ORG_ID}" \
        >/dev/null 2>&1 \
        && echo "✓ ${CONSTRAINT_NAME} deleted." \
        || echo "✓ ${CONSTRAINT_NAME} not found. Skipping."
}

delete_constraint "custom.requireEnvironmentLabels"
delete_constraint "custom.requireApplicationLabels"
delete_constraint "custom.requireOwnerLabels"

echo ""
echo "======================================"
echo "All Governance Artefacts Deleted"
echo "======================================"

echo ""
echo "Removed:"
echo "  ✓ IAM Deny Policies"
echo "  ✓ Org Policies"
echo "  ✓ Custom Constraints"

echo ""
echo "Verify using:"
echo "    ./scripts/verify-all.sh"

echo ""
