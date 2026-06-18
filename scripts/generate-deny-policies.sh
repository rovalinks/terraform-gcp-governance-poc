#!/bin/bash

source ./scripts/config.sh

mkdir -p iam-deny/generated

for f in iam-deny/templates/*.yaml
do
  sed "s/__ADMIN_EMAIL__/${GOVERNANCE_ADMIN_EMAIL}/g" \
      "$f" \
      > "iam-deny/generated/$(basename "$f")"
done