#!/bin/bash

set -euo pipefail

source scripts/config.sh

mkdir -p org-policies/generated/custom-constraints
mkdir -p org-policies/generated/policies

CONFIG_FILE="config/customer.auto.tfvars"

ENVIRONMENT_REGEX=$(awk '
/environments *= *\[/ {flag=1; next}
/]/ {flag=0}
flag {gsub(/"|,| /,""); printf "%s|",$0}
' "$CONFIG_FILE" | sed 's/|$//')

OWNER_REGEX=$(awk '
/owners *= *\[/ {flag=1; next}
/]/ {flag=0}
flag {gsub(/"|,| /,""); printf "%s|",$0}
' "$CONFIG_FILE" | sed 's/|$//')

APPLICATION_REGEX=$(awk '
/applications *= *\[/ {flag=1; next}
/]/ {flag=0}
flag {gsub(/"|,| /,""); printf "%s|",$0}
' "$CONFIG_FILE" | sed 's/|$//')

find org-policies/templates -name "*.yaml" | while read file
do
  target=$(echo "$file" | sed 's/templates/generated/')

  sed \
    -e "s/__ORG_ID__/${ORGANIZATION_ID}/g" \
    -e "s/__ENVIRONMENT_REGEX__/${ENVIRONMENT_REGEX}/g" \
    -e "s/__OWNER_REGEX__/${OWNER_REGEX}/g" \
    -e "s/__APPLICATION_REGEX__/${APPLICATION_REGEX}/g" \
    "$file" > "$target"
done

echo ""
echo "Generated organisation policies."
echo "Environment Regex : ${ENVIRONMENT_REGEX}"
echo "Owner Regex       : ${OWNER_REGEX}"
echo "Application Regex : ${APPLICATION_REGEX}"
echo ""