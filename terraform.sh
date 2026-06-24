#!/bin/bash
# wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
#   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
#   sudo apt update && sudo apt install terraform
#   bash
#!/bin/bash

#!/bin/bash

# --- 1. ENVIRONMENT SELECTOR & EXECUTION ---
echo "Select Environment:"
echo "1) dev"
echo "2) test"
echo "3) uat"
echo "4) prod"

read -p "Enter choice [1-4]: " choice

case $choice in
    1)  ENV="dev" ;;
    2)  ENV="test" ;;
    3)  ENV="uat" ;;
    4)  ENV="prod" ;;
    *)
        echo -e "\nEnvironment must be one of: dev, test, uat, prod. \n\nPlease select valid environment to proceed further\n"
        exit 1
        ;;
esac

cd terraform/environments/$ENV || exit 1

echo ""
echo "Selected environment: $ENV"
echo ""

# Execute the Terraform action (e.g., init, plan, apply)
terraform "$@"

# Store the exit code of the terraform command
TF_EXIT_CODE=$?

# Return to the root repository folder to run the generation scripts
cd - > /dev/null


# --- 2. GENERATE CONFIGS & POLICIES (RUNS AFTER TERRAFORM) ---
# Only run generation if Terraform succeeded or if it was an 'apply'
if [ $TF_EXIT_CODE -eq 0 ]; then
    
    echo -e "\n--- Post-Terraform Execution Tasks ---"
    
    # Generate Environment Configs
    echo "Generating customer configurations..."
    CONFIG_FILE="config/customer.auto.tfvars"
    mkdir -p "terraform/environments/$ENV"
    cp "$CONFIG_FILE" "terraform/environments/$ENV/customer.auto.tfvars"
    echo -e "Customer configuration copied successfully.\n"

    # Generate Deny Policies
    echo "Generating IAM Deny policies..."
    if [ -f "./scripts/config.sh" ]; then
        pushd scripts > /dev/null
        source ./config.sh
        popd > /dev/null
    else
        echo "Warning: ./scripts/config.sh not found. Skipping Deny policy generation."
    fi

    mkdir -p iam-deny/generated
    for f in iam-deny/templates/*.yaml
    do
        [ -e "$f" ] || continue
        sed "s/__ADMIN_EMAIL__/${GOVERNANCE_ADMIN_EMAIL}/g" \
            "$f" \
            > "iam-deny/generated/$(basename "$f")"
done
    echo -e "IAM Deny policies generated successfully.\n"

fi

# Exit with the original Terraform exit code
exit $TF_EXIT_CODE
