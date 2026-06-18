#!/bin/bash
set -e

CONFIG_FILE="config/customer.auto.tfvars"

for ENV in dev test uat prod
do
cp "$CONFIG_FILE" "terraform/environments/$ENV/customer.auto.tfvars"
done

echo ""
echo "Customer configuration copied successfully."
echo ""

for ENV in dev test uat prod
do
echo "Generated:"
echo " terraform/environments/$ENV/customer.auto.tfvars"
done
