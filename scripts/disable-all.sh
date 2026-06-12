#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/config.sh"

echo "======================================"
echo "Disabling Governance Enforcement"
echo "======================================"

echo ""
echo "======================================"
echo "Removing IAM Deny Policies"
echo "======================================"

delete_deny_policy() {
    POLICY_ID=$1

    echo "Removing ${POLICY_ID}..."

    gcloud iam policies delete "${POLICY_ID}" \
        --attachment-point="cloudresourcemanager.googleapis.com/projects/${PROJECT_NUMBER}" \
        --kind=denypolicies \
        >/dev/null 2>&1 \
        && echo "✓ ${POLICY_ID} removed." \
        || echo "✓ ${POLICY_ID} not found. Skipping."
}

delete_deny_policy "deny-vm-create"
delete_deny_policy "deny-disk-create"
delete_deny_policy "deny-snapshot-create"

echo ""
echo "======================================"
echo "Disabling Org Policies"
echo "======================================"

disable_policy() {
    POLICY_NAME=$1

    echo "Removing ${POLICY_NAME}..."

    gcloud org-policies delete "${POLICY_NAME}" \
        --organization="${ORG_ID}" \
        >/dev/null 2>&1 \
        && echo "✓ ${POLICY_NAME} removed." \
        || echo "✓ ${POLICY_NAME} not found. Skipping."
}

disable_policy "custom.requireEnvironmentLabel1"
disable_policy "custom.requireApplicationLabel1"
disable_policy "custom.requireOwnerLabel1"

echo ""
echo "======================================"
echo "Governance Enforcement Disabled"
echo "======================================"

echo ""
echo "Retained:"
echo "  ✓ Custom Constraints"

echo ""
echo "Removed:"
echo "  ✓ IAM Deny Policies"
echo "  ✓ Org Policies"

echo ""
echo "To re-enable governance run:"
echo "    ./scripts/enable-all.sh"

echo ""
