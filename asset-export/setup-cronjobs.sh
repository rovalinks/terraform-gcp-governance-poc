#!/bin/bash
set -e

# Configuration Variables
export GCP_REGION="europe-west2"
export PROJECT_ID=$(gcloud config get-value project)
export WORKFLOW_SA="cai-workflow-sa@${PROJECT_ID}.iam.gserviceaccount.com"

echo "⏱️ Configuring automated operational schedules..."

# Clear existing cron instances to avoid update conflicts
gcloud scheduler jobs delete cai-export-job --location="$GCP_REGION" --quiet || true
gcloud scheduler jobs delete cai-cleanup-job --location="$GCP_REGION" --quiet || true

# Provision Export Job -> Runs every 10 minutes
gcloud scheduler jobs create http cai-export-job \
    --schedule="*/10 * * * *" \
    --location="$GCP_REGION" \
    --uri="https://workflowexecutions.googleapis.com/v1/projects/${PROJECT_ID}/locations/${GCP_REGION}/workflows/cai-export-workflow/executions" \
    --oauth-service-account-email="$WORKFLOW_SA"

# Provision Cleanup Job -> Runs every 3 hours
gcloud scheduler jobs create http cai-cleanup-job \
    --schedule="0 */3 * * *" \
    --location="$GCP_REGION" \
    --uri="https://workflowexecutions.googleapis.com/v1/projects/${PROJECT_ID}/locations/${GCP_REGION}/workflows/cai-cleanup-workflow/executions" \
    --oauth-service-account-email="$WORKFLOW_SA"

# Execute a manual run right now to kick things off and verify everything works
echo "🏃 Testing pipeline run..."
gcloud scheduler jobs run cai-export-job --location="$GCP_REGION"

echo "=== ✅ Scheduler Pipelines Active and Online ==="
