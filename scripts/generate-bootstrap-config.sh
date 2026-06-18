#!/bin/bash

source scripts/config.sh

cat > bootstrap/tags/bootstrap.auto.tfvars <<EOF
project_id = "${PROJECT_ID}"
org_id     = "${ORGANIZATION_ID}"
EOF
