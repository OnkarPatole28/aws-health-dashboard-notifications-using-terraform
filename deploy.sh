#!/bin/bash

# Check if the Terraform is installed
if ! command -v terraform &> /dev/null
then
    echo "Terraform could not be found. Please install Terraform and try again."
    exit 1
fi

# Setting the path to the credentials file
CREDENTIALS_FILE="credentials.tfvars"

# Check if credentials file exists or not
if [[ ! -f "$CREDENTIALS_FILE" ]]; then
  echo "Credentials file not found! Please create credentials.tfvars with AWS credentials and email."
  exit 1
fi

# Initialize Terraform (download necessary providers)
echo "Initializing Terraform..."
terraform init

# Validate Terraform configuration
echo "Validating Terraform configuration..."
terraform validate
if [ $? -ne 0 ]; then
  echo "Terraform validation failed. Please check your configuration."
  exit 1
fi

# Apply Terraform configuration with credentials
echo "Applying Terraform configuration..."
terraform apply -var-file="$CREDENTIALS_FILE" -auto-approve

# Check if the apply command was successful
if [ $? -eq 0 ]; then
  echo "Terraform applied successfully."
else
  echo "Terraform apply failed."
  exit 1
fi
