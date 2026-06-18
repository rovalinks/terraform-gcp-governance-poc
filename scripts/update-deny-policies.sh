#!/bin/bash

source scripts/config.sh

find iam-deny -name "*.yaml" -type f -exec \
sed -i "s/__ADMIN_EMAIL__/${GOVERNANCE_ADMIN_EMAIL}/g" {} \;