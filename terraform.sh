#!/bin/bash
# wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
#   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
#   sudo apt update && sudo apt install terraform

#!/bin/bash

# --- 1. ENVIRONMENT SELECTOR ---
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


# --- 2. GENERATE CONFIGS & POLICIES BEFORE TERRAFORM RUNS (ONLY ON 'PLAN') ---
if [ "$1" = "plan" ]; then
    
    echo -e "\n--- Pre-Plan Execution Tasks ---"
    
    # TASK A: Generate Environment Configs
    echo "Generating customer configurations..."
    CONFIG_FILE="config/customer.auto.tfvars"
    mkdir -p "terraform/environments/$ENV"
    cp "$CONFIG_FILE" "terraform/environments/$ENV/customer.auto.tfvars"
    echo -e "Customer configuration copied successfully.\n"

    # EXTRA STEP: Source Environment Variables Safely
    if [ -f "./scripts/config.sh" ]; then
        pushd scripts > /dev/null
        source ./config.sh
        popd > /dev/null
    else
        echo "Error: ./scripts/config.sh not found. Cannot generate policies."
        exit 1
    fi

    # TASK B: Generate IAM Deny Policies
    echo "Generating IAM Deny policies..."
    mkdir -p iam-deny/generated
    for f in iam-deny/templates/*.yaml
    do
        [ -e "$f" ] || continue
        sed "s/__ADMIN_EMAIL__/${GOVERNANCE_ADMIN_EMAIL}/g" \
            "$f" \
            > "iam-deny/generated/$(basename "$f")"
    done
    echo -e "IAM Deny policies generated successfully.\n"

    # TASK C: Generate Org Policies
    echo "Generating Organisation policies..."
    mkdir -p org-policies/generated/custom-constraints
    mkdir -p org-policies/generated/policies

    if [ -d "org-policies/templates" ]; then
        find org-policies/templates -name "*.yaml" | while read -r file; do
          filename=$(basename "$file")

          if [[ "$filename" == *"label.yaml" ]]; then
            target="org-policies/generated/custom-constraints/$filename"
          else
            target="org-policies/generated/policies/$filename"
          fi

          sed \
            -e "s/__ORG_ID__/${ORGANIZATION_ID}/g" \
            -e "s/__ENVIRONMENT_REGEX__/${ENVIRONMENT_REGEX}/g" \
            -e "s/__OWNER_REGEX__/${OWNER_REGEX}/g" \
            -e "s/__APPLICATION_REGEX__/${APPLICATION_REGEX}/g" \
            "$file" > "$target"
        done

        echo "Organisation policies generated successfully."
        echo "Environment Regex : ${ENVIRONMENT_REGEX}"
        echo "Owner Regex       : ${OWNER_REGEX}"
        echo "Application Regex : ${APPLICATION_REGEX}"
        echo ""
    else
        echo "Warning: org-policies/templates directory not found. Skipping Org policy generation."
    fi
fi


# --- 3. EXECUTE TERRAFORM ---
cd terraform/environments/$ENV || exit 1

echo ""
echo "Selected environment: $ENV"
echo ""

# Execute the Terraform action (e.g., plan)
terraform "$@"

# Store and exit with the final Terraform code
TF_EXIT_CODE=$?
exit $TF_EXIT_CODE
