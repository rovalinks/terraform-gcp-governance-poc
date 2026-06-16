#!/bin/bash
set -e

# Configuration Variables
export GCP_REGION="europe-west2"
export PROJECT_ID=$(gcloud config get-value project)
export WORKFLOW_SA="cai-workflow-sa@${PROJECT_ID}.iam.gserviceaccount.com"

echo "🎯 Deploying workflows to Project: $PROJECT_ID in Region: $GCP_REGION..."

# Create directory if missing
mkdir -p scripts

# Deploy Export Workflow
gcloud workflows deploy cai-export-workflow \
    --source=scripts/export-workflow.yaml \
    --location="$GCP_REGION"

# Deploy Cleanup Workflow
gcloud workflows deploy cai-cleanup-workflow \
    --source=scripts/cleanup-workflow.yaml \
    --location="$GCP_REGION"

echo "=== ✅ Workflows Deployed Successfully ==="
