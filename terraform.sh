#!/bin/bash
# wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
#   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
#   sudo apt update && sudo apt install terraform
#   bash

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
        echo -e "\nEnvironment must be one of: dev, test, uat, prod. \n\nPlease select valid environment to proceed futher\n"
        exit 1
        ;;
esac

cd terraform/environments/$ENV || exit 1

echo ""
echo "Selected environment: $ENV"
echo ""

terraform "$@"
