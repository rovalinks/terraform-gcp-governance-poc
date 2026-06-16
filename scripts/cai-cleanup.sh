#!/bin/bash

PROJECT_ID="project-a9c3b175-7f78-4ba6-9ad"
DATASET="governance_inventory"

CUTOFF=$(date -u -d "1 day ago" +%Y%m%d_%H%M)

for TABLE in $(bq ls --project_id=${PROJECT_ID} ${DATASET} \
  | awk '/asset_export_/ {print $1}'); do

  TABLE_TS=$(echo "$TABLE" | sed 's/asset_export_//')

  if [[ "$TABLE_TS" < "$CUTOFF" ]]; then
    echo "Deleting ${TABLE}"
    bq rm -f -t "${PROJECT_ID}:${DATASET}.${TABLE}"
  fi

done
