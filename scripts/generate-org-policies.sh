#!/bin/bash

set -euo pipefail

# Load environment configurations
source scripts/config.sh

# Ensure the destination directories exist
mkdir -p org-policies/generated/custom-constraints
mkdir -p org-policies/generated/policies

CONFIG_FILE="config/customer.auto.tfvars"

# ... (Keep your existing regex generation logic here) ...

# Process template files
find org-policies/templates -name "*.yaml" | while read -r file; do
  filename=$(basename "$file")

  # Logic: Route based on filename
  if [[ "$filename" == *"label.yaml" ]]; then
    target="org-policies/generated/custom-constraints/$filename"
  else
    target="org-policies/generated/policies/$filename"
  fi

  # Apply template substitutions
  sed \
    -e "s/__ORG_ID__/${ORGANIZATION_ID}/g" \
    -e "s/__ENVIRONMENT_REGEX__/${ENVIRONMENT_REGEX}/g" \
    -e "s/__OWNER_REGEX__/${OWNER_REGEX}/g" \
    -e "s/__APPLICATION_REGEX__/${APPLICATION_REGEX}/g" \
    "$file" > "$target"
done

echo "Policies generated successfully."
echo ""
echo "Generated organisation policies."
echo "Environment Regex : ${ENVIRONMENT_REGEX}"
echo "Owner Regex       : ${OWNER_REGEX}"
echo "Application Regex : ${APPLICATION_REGEX}"
echo ""