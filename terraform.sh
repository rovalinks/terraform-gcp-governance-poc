#!/bin/bash

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
        echo "Invalid selection."
        exit 1
        ;;
esac

cd terraform/environments/$ENV || exit 1

echo ""
echo "Selected environment: $ENV"
echo ""

terraform "$@"
