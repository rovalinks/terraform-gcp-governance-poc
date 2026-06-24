#!/bin/bash
# wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
#   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
#   sudo apt update && sudo apt install terraform
#   bash
#!/bin/bash

# --- 1. GENERATE ENVIRONMENT CONFIGS ---
echo "Generating customer configurations..."
CONFIG_FILE="config/customer.auto.tfvars"

for ENV in dev test uat prod
do
    # Ensure target directory exists before copying
    mkdir -p "terraform/environments/$ENV"
    cp "$CONFIG_FILE" "terraform/environments/$ENV/customer.auto.tfvars"
done

echo -e "Customer configuration copied successfully.\n"


# --- 2. GENERATE DENY POLICIES ---
echo "Generating IAM Deny policies..."
# Source your governance config variables
if [ -f "./scripts/config.sh" ]; then
    source ./scripts/config.sh
else
    echo "Warning: ./scripts/config.sh not found. Skipping Deny policy generation."
fi

mkdir -p iam-deny/generated

for f in iam-deny/templates/*.yaml
do
    # Check if templates actually exist to avoid errors
    [ -e "$f" ] || continue
    sed "s/__ADMIN_EMAIL__/${GOVERNANCE_ADMIN_EMAIL}/g" \
        "$f" \
        > "iam-deny/generated/$(basename "$f")"
done

echo -e "IAM Deny policies generated successfully.\n"


# --- 3. ENVIRONMENT SELECTOR & EXECUTION ---
echo "Select Environment:"
echo "1) dev"
echo "2) test"
echo "3) uat"
echo "4) prod"

read -p "Enter choice [1-4]: " choice

case $choice in
    1)
        ENV="dev"
        ;;
    2)
        ENV="test"
        ;;
    3)  ENV="uat"
        ;;
    4)  ENV="prod"
        ;;
    *)
        echo -e "\nEnvironment must be one of: dev, test, uat, prod. \n\nPlease select valid environment to proceed further\n"
        exit 1
        ;;
esac

cd terraform/environments/$ENV || exit 1

echo ""
echo "Selected environment: $ENV"
echo ""

# Execute whatever argument you pass to terraform.sh (e.g., ./terraform.sh plan)
terraform "$@"
