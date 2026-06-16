#!/bin/bash
set -e

export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

export WORKFLOW_SA="cai-workflow-sa@${PROJECT_ID}.iam.gserviceaccount.com"
export SCHEDULER_SA="service-${PROJECT_NUMBER}@gcp-sa-cloudscheduler.iam.gserviceaccount.com"

echo "🔐 Fetching policy settings for validation..."
CURRENT_POLICY=$(gcloud projects get-iam-policy "$PROJECT_ID" --format="json")

# 1. Check/Add Workflows Invoker
if echo "$CURRENT_POLICY" | grep -q "$WORKFLOW_SA" && echo "$CURRENT_POLICY" | grep -q "roles/workflows.invoker"; then
    echo "✅ Workflows Invoker role already exists. Skipping."
else
    echo "➕ Adding Workflows Invoker role..."
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
        --member="serviceAccount:$WORKFLOW_SA" \
        --role="roles/workflows.invoker" \
        --condition=None
fi

# 2. Check/Add Cloud Scheduler Token Creator
if echo "$CURRENT_POLICY" | grep -q "$SCHEDULER_SA" && echo "$CURRENT_POLICY" | grep -q "roles/iam.serviceAccountTokenCreator"; then
    echo "✅ Token Creator role already exists. Skipping."
else
    echo "➕ Adding Service Account Token Creator role..."
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
        --member="serviceAccount:$SCHEDULER_SA" \
        --role="roles/iam.serviceAccountTokenCreator" \
        --condition=None
fi
