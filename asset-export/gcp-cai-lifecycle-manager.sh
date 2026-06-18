#!/bin/bash

# Exit on error
set -e

echo "=== 🚀 STARTING FULL AUTOMATED COMPLIANCE DEPLOYMENT ==="

# -------------------------------------------------------------------------
# 1. Configuration & Dynamic Environment Discovery
# -------------------------------------------------------------------------
# Change this region value to deploy your infrastructure elsewhere
source scripts/config.sh

export GCP_REGION="${REGION}"

export GOVERNANCE_DATASET="${GOVERNANCE_DATASET}"

export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

if [ -z "$PROJECT_ID" ]; then
    echo "❌ ERROR: No active GCP project found in gcloud config. Run 'gcloud config set project [PROJECT_ID]' first."
    exit 1
fi

echo "🎯 Target Project ID:     $PROJECT_ID"
echo "🔢 Target Project Number: $PROJECT_NUMBER"
echo "📍 Target Deployment Region: $GCP_REGION"

# Ensure target script directories exist
mkdir -p scripts

# -------------------------------------------------------------------------
# 2. Generate the Dynamic Asset Export Workflow File
# -------------------------------------------------------------------------
echo "📝 Writing asset-export/export-workflow.yaml..."
cat << EOF > asset-export/export-workflow.yaml
main:
  steps:
    - generateTimestamp:
        assign:
          - current_time: \${time.format(sys.now())}
          - year: \${text.substring(current_time, 0, 4)}
          - month: \${text.substring(current_time, 5, 7)}
          - day: \${text.substring(current_time, 8, 10)}
          - hour: \${text.substring(current_time, 11, 13)}
          - minute: \${text.substring(current_time, 14, 16)}
          - second: \${text.substring(current_time, 17, 19)}
          - ts: \${day + "_" + month + "_" + year + "_" + hour + minute + second}

    - exportAssets:
        call: http.post
        args:
          url: "https://cloudasset.googleapis.com/v1/projects/${PROJECT_ID}:exportAssets"
          auth:
            type: OAuth2
          body:
            contentType: RESOURCE
            assetTypes:
              - bigquery.googleapis.com/Dataset
              - storage.googleapis.com/Bucket
              - compute.googleapis.com/Disk
              - compute.googleapis.com/ForwardingRule
              - compute.googleapis.com/Address
              - pubsub.googleapis.com/Topic
              - container.googleapis.com/NodePool
              - artifactregistry.googleapis.com/Repository
              - compute.googleapis.com/InstanceTemplate
              - sqladmin.googleapis.com/Instance
              - container.googleapis.com/Cluster
              - compute.googleapis.com/InstanceGroupManager
              - compute.googleapis.com/Instance
            outputConfig:
              bigqueryDestination:
                dataset: "projects/${PROJECT_ID}/datasets/${GOVERNANCE_DATASET}"
                table: \${"asset_export_" + ts}
                force: true
        result: exportResult

    - returnResult:
        return: \${exportResult.body}
EOF

# -------------------------------------------------------------------------
# 3. Generate the Dynamic Cleanup Workflow File
# -------------------------------------------------------------------------
echo "📝 Writing asset-export/cleanup-workflow.yaml..."
cat << EOF > asset-export/cleanup-workflow.yaml
main:
  steps:
    - listTables:
        call: http.get
        args:
          url: "https://bigquery.googleapis.com/bigquery/v2/projects/${PROJECT_ID}/datasets/${GOVERNANCE_DATASET}/tables"
          auth:
            type: OAuth2
        result: tablesResponse

    - deleteOldTables:
        for:
          value: table
          in: \${default(map.get(tablesResponse.body, "tables"), [])}
          steps:
            - extractName:
                assign:
                  - tableId: \${table.tableReference.tableId}

            - checkExportTable:
                switch:
                  - condition: \${text.match_regex(tableId, "^asset_export_[0-9]{2}_[0-9]{2}_[0-9]{4}_[0-9]{6}$")}
                    next: evaluateAge
                next: continueLoop

            - evaluateAge:
                assign:
                  - parts: \${text.split(tableId, "_")}
                  - d: \${parts[2]}
                  - m: \${parts[3]}
                  - y: \${parts[4]}
                  - hhmmss: \${parts[5]}
                  - hh: \${text.substring(hhmmss, 0, 2)}
                  - mm: \${text.substring(hhmmss, 2, 4)}
                  - ss: \${text.substring(hhmmss, 4, 6)}
                  - table_time: \${time.parse(y + "-" + m + "-" + d + "T" + hh + ":" + mm + ":" + ss + "Z")}
                  - time_now: \${sys.now()}
                  - age_seconds: \${time_now - table_time}

            - checkAgeCondition:
                switch:
                  - condition: \${age_seconds > 3600}
                    next: deleteTable
                next: continueLoop

            - deleteTable:
                call: http.delete
                args:
                  url: \${"https://bigquery.googleapis.com/bigquery/v2/projects/${PROJECT_ID}/datasets/${GOVERNANCE_DATASET}/tables/" + tableId}
                  auth:
                    type: OAuth2

            - continueLoop:
                next: endLoop

            - endLoop:
                assign:
                  - dummy: ""

    - done:
        return: "Cleanup completed successfully"
EOF

# -------------------------------------------------------------------------
# 4. Deploy Workflows Dynamically to $GCP_REGION
# -------------------------------------------------------------------------
echo "🚀 Deploying 'cai-export-workflow' to ${GCP_REGION}..."
gcloud workflows deploy cai-export-workflow \
    --source=asset-export/export-workflow.yaml \
    --location="$GCP_REGION"

echo "🚀 Deploying 'cai-cleanup-workflow' to ${GCP_REGION}..."
gcloud workflows deploy cai-cleanup-workflow \
    --source=asset-export/cleanup-workflow.yaml \
    --location="$GCP_REGION"

# -------------------------------------------------------------------------
# 5. Smart Identity Access & Roles (Idempotent Check)
# -------------------------------------------------------------------------
echo "🔐 Verifying IAM permissions to prevent duplicate structural writes..."

CURRENT_POLICY=$(gcloud projects get-iam-policy "$PROJECT_ID" --format="json")

WORKFLOW_SA="cai-workflow-sa@${PROJECT_ID}.iam.gserviceaccount.com"
SCHEDULER_SA="service-${PROJECT_NUMBER}@gcp-sa-cloudscheduler.iam.gserviceaccount.com"

# Check Workflows Invoker Permission
if echo "$CURRENT_POLICY" | grep -q "$WORKFLOW_SA" && echo "$CURRENT_POLICY" | grep -q "roles/workflows.invoker"; then
    echo "✅ Workflows Invoker role already assigned to $WORKFLOW_SA. Skipping."
else
    echo "➕ Adding Workflows Invoker role..."
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
        --member="serviceAccount:$WORKFLOW_SA" \
        --role="roles/workflows.invoker" \
        --condition=None
fi

# Check Cloud Scheduler Token Creator Impersonation
if echo "$CURRENT_POLICY" | grep -q "$SCHEDULER_SA" && echo "$CURRENT_POLICY" | grep -q "roles/iam.serviceAccountTokenCreator"; then
    echo "✅ Token Creator role already assigned to Cloud Scheduler. Skipping."
else
    echo "➕ Adding Service Account Token Creator role..."
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
        --member="serviceAccount:$SCHEDULER_SA" \
        --role="roles/iam.serviceAccountTokenCreator" \
        --condition=None
fi

# -------------------------------------------------------------------------
# 6. Re-configure Cloud Scheduler Schedules Dynamically
# -------------------------------------------------------------------------
echo "⏱️ Refreshing Cloud Scheduler Job Configs in ${GCP_REGION}..."

gcloud scheduler jobs delete cai-export-job --location="$GCP_REGION" --quiet || true
gcloud scheduler jobs delete cai-cleanup-job --location="$GCP_REGION" --quiet || true

# Recreate Export Job (Every 10 Mins)
gcloud scheduler jobs create http cai-export-job \
    --schedule="*/10 * * * *" \
    --location="$GCP_REGION" \
    --uri="https://workflowexecutions.googleapis.com/v1/projects/${PROJECT_ID}/locations/${GCP_REGION}/workflows/cai-export-workflow/executions" \
    --oauth-service-account-email="$WORKFLOW_SA"

# Recreate Cleanup Job (Every 3 Hours)
gcloud scheduler jobs create http cai-cleanup-job \
    --schedule="*/30 * * * *" \
    --location="$GCP_REGION" \
    --uri="https://workflowexecutions.googleapis.com/v1/projects/${PROJECT_ID}/locations/${GCP_REGION}/workflows/cai-cleanup-workflow/executions" \
    --oauth-service-account-email="$WORKFLOW_SA"

# -------------------------------------------------------------------------
# 7. Final Smoke Test Run
# -------------------------------------------------------------------------
echo "🏃 Running immediate test pipelines to verify..."
gcloud scheduler jobs run cai-export-job --location="$GCP_REGION"

echo "=== ✅ SUCCESSFUL PLUG-AND-PLAY DEPLOYMENT COMPLETION ==="
echo "Your inventory tables are now running safely on automated intervals!"
