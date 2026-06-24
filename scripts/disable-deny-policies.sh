#!/bin/bash

set -e

PROJECT_ID=$(gcloud config get-value project)

echo "Project: ${PROJECT_ID}"

for file in iam-deny/generated/*.yaml
do
    POLICY_NAME=$(basename "$file" .yaml)

    echo "Deleting ${POLICY_NAME}"

    gcloud iam policies delete "${POLICY_NAME}" \
      --attachment-point="cloudresourcemanager.googleapis.com/projects/${PROJECT_ID}" \
      --kind="denypolicies" \
      --quiet || true

done

echo "All deny policies removed."