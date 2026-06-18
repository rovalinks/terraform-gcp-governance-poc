#!/bin/bash

source scripts/config.sh

mkdir -p org-policies/generated/custom-constraints
mkdir -p org-policies/generated/policies

find org-policies/templates -name "*.yaml" | while read file
do
  target=$(echo "$file" | sed 's/templates/generated/')

  sed "s/__ORG_ID__/${ORGANIZATION_ID}/g" "$file" > "$target"
done
