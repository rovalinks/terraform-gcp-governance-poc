#!/bin/bash
set -euo pipefail

source scripts/config.sh

mkdir -p asset-export/generated

for file in asset-export/templates/*.yaml
do
    target="asset-export/generated/$(basename "$file")"

    sed \
      -e "s/__PROJECT_ID__/${PROJECT_ID}/g" \
      -e "s/__DATASET_NAME__/${GOVERNANCE_DATASET}/g" \
      "$file" > "$target"
done

echo "Workflow files generated successfully."