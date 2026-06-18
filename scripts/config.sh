# --------------------------------------------------
# HOW TO FIND PROJECT ID
# --------------------------------------------------
# gcloud config get-value project
#
# Example Output:
# project-a9c3b175-7f78-4ba6-9ad
#
# export PROJECT_ID="project-a9c3b175-7f78-4ba6-9ad"


# --------------------------------------------------
# HOW TO FIND PROJECT NUMBER
# --------------------------------------------------
# gcloud projects describe $(gcloud config get-value project) \
#   --format="value(projectNumber)"
#
# Example Output:
# 106228803995
#
# export PROJECT_NUMBER="106228803995"


# --------------------------------------------------
# HOW TO FIND ORGANIZATION ID
# --------------------------------------------------
# gcloud organizations list
#
# Example Output:
# DISPLAY_NAME     ID
# customer-org     123456789012
#
# export ORGANIZATION_ID="123456789012"


# --------------------------------------------------
# HOW TO FIND GOVERNANCE ADMIN EMAIL
# --------------------------------------------------
# Email account that should be exempt from IAM Deny policies.
#
# Example:
# export GOVERNANCE_ADMIN_EMAIL="admin@customer.com"


# --------------------------------------------------
# HOW TO FIND REGION AND ZONE
# --------------------------------------------------
# gcloud compute zones list
#
# Example:
# export REGION="europe-west2"
# export ZONE="europe-west2-a"

#!/bin/bash

set -euo pipefail

CONFIG_FILE="$(dirname "$0")/../config/customer.auto.tfvars"

export PROJECT_ID=$(grep '^project_id' "$CONFIG_FILE" | cut -d'"' -f2)
export PROJECT_NUMBER=$(grep '^project_number' "$CONFIG_FILE" | cut -d'"' -f2)
export ORGANIZATION_ID=$(grep '^org_id' "$CONFIG_FILE" | cut -d'"' -f2)
export REGION=$(grep '^region' "$CONFIG_FILE" | cut -d'"' -f2)
export ZONE=$(grep '^zone' "$CONFIG_FILE" | cut -d'"' -f2)

export GOVERNANCE_ADMIN_EMAIL=${GOVERNANCE_ADMIN_EMAIL:-rohith555raju@gmail.com}
export GOVERNANCE_DATASET=${GOVERNANCE_DATASET:-governance_inventory}
