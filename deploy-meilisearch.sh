#!/bin/bash

set -e
set -o pipefail

# === CONFIGURATION ===
PROJECT_ID="YOUR_PROJECT_ID"         # <-- CHANGE THIS
REGION="us-central1"
ZONE="us-central1-a"
TERRAFORM_DIR="."                    # Or path to your Terraform folder

# === PREREQUISITES ===

# Install gcloud CLI if not present
if ! command -v gcloud &> /dev/null; then
  echo "Installing gcloud CLI..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install --cask google-cloud-sdk
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates gnupg
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
      sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
      sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    sudo apt-get update && sudo apt-get install -y google-cloud-sdk
  fi
fi

# Install terraform if not present
if ! command -v terraform &> /dev/null; then
  echo "Installing Terraform..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt-get update && sudo apt-get install -y wget unzip
    wget https://releases.hashicorp.com/terraform/1.8.5/terraform_1.8.5_linux_amd64.zip
    unzip terraform_1.8.5_linux_amd64.zip
    sudo mv terraform /usr/local/bin/
    rm terraform_1.8.5_linux_amd64.zip
  fi
fi

# === GCP LOGIN ===
echo "🔐 Logging into GCP..."
gcloud auth application-default login
gcloud config set project "$PROJECT_ID"

# === TERRAFORM ===
cd "$TERRAFORM_DIR"
echo "📦 Initializing Terraform..."
terraform init

echo "🚀 Deploying MeiliSearch with Terraform..."
terraform apply -var="project_id=$PROJECT_ID" -auto-approve

echo "✅ Deployment complete!"

# Optional: Output IP
echo "🌐 Public IP:"
terraform output meilisearch_static_ip || echo "Add 'output meilisearch_static_ip' in main.tf to display it"
