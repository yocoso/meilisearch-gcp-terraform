# MeiliSearch on Google Cloud Platform with Terraform

This repository contains Terraform configuration to deploy [MeiliSearch](https://www.meilisearch.com/) on Google Cloud Platform (GCP) using a Compute Engine instance.

## 🏗️ Architecture

The infrastructure includes:

-   **Compute Engine VM** (e2-micro) running Debian 11
-   **Static IP address** for consistent access
-   **Firewall rule** allowing traffic on port 7700
-   **Docker container** running MeiliSearch v1.7
-   **Persistent storage** for MeiliSearch data

## 📋 Prerequisites

Before deploying, ensure you have:

1. **Google Cloud Project** with billing enabled
2. **Required APIs enabled**:
    - [Compute Engine API](https://console.cloud.google.com/apis/library/compute.googleapis.com)
    - [Cloud Resource Manager API](https://console.cloud.google.com/apis/library/cloudresourcemanager.googleapis.com)
3. **Local tools** (auto-installed by deploy script):
    - [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)
    - [Terraform](https://www.terraform.io/downloads)

## 🚀 Quick Start

### Option 1: Automated Deployment

1. **Clone the repository**:

    ```bash
    git clone https://github.com/yocoso/meilisearch-gcp-terraform
    cd meilisearch-gcp-terraform
    ```

2. **Update configuration**:

    a. Edit `deploy-meilisearch.sh` and change the `PROJECT_ID`:

    ```bash
    PROJECT_ID="your-gcp-project-id"  # <-- CHANGE THIS
    ```

    b. Edit `variables.tf` and update the project_id variable:

    ```hcl
    variable "project_id" {
      description = "your-gcp-project-id"  # <-- CHANGE THIS
      type        = string
    }
    ```

3. **Run the deployment script**:
    ```bash
    chmod +x deploy-meilisearch.sh
    ./deploy-meilisearch.sh
    ```

### Option 2: Manual Deployment

1. **Authenticate with GCP**:

    ```bash
    gcloud auth application-default login
    gcloud config set project YOUR_PROJECT_ID
    ```

2. **Initialize Terraform**:

    ```bash
    terraform init
    ```

3. **Plan the deployment**:

    ```bash
    terraform plan -var="project_id=YOUR_PROJECT_ID"
    ```

4. **Apply the configuration**:
    ```bash
    terraform apply -var="project_id=YOUR_PROJECT_ID"
    ```

## ⚙️ Configuration

### Variables

You can customize the deployment by modifying `variables.tf` or passing variables:

| Variable     | Description    | Default         |
| ------------ | -------------- | --------------- |
| `project_id` | GCP Project ID | Required        |
| `region`     | GCP Region     | `us-central1`   |
| `zone`       | GCP Zone       | `us-central1-a` |

### MeiliSearch Configuration

The MeiliSearch instance is configured with:

-   **Port**: 7700
-   **Master Key**: `mysecuremasterkey` (⚠️ **Change this in production!**)
-   **Data Path**: `/opt/meili_data` (persistent storage)

## 🔒 Security Considerations

⚠️ **Important Security Notes**:

1. **Change the master key**: The default master key in `startup.sh` is for demo purposes only
2. **Restrict firewall access**: Consider limiting `source_ranges` in the firewall rule
3. **Use HTTPS**: Consider setting up SSL/TLS for production use
4. **Update regularly**: Keep MeiliSearch and the OS updated

### Updating the Master Key

Edit `startup.sh` and change the master key:

```bash
# Change this line:
meilisearch --db-path /meili_data --master-key YOUR_SECURE_MASTER_KEY
```

## 📡 Accessing MeiliSearch

After deployment:

1. **Get the public IP**:

    ```bash
    terraform output
    ```

2. **Access MeiliSearch**:

    - API: `http://YOUR_IP:7700`
    - Health check: `http://YOUR_IP:7700/health`

3. **Test the API**:
    ```bash
    curl -X GET 'http://YOUR_IP:7700/health'
    ```

## 🎛️ Setting Up the Dashboard

MeiliSearch doesn't include a built-in dashboard, but you can use community-built UI tools for easier management:

### Mini Dashboard (Official)

Use the official MeiliSearch mini-dashboard:

1. **Clone the official mini dashboard**:

    ```bash
    git clone https://github.com/meilisearch/mini-dashboard.git
    cd mini-dashboard
    ```

2. **Install dependencies**:

    ```bash
    yarn
    ```

3. **Build and serve**:

    ```bash
    REACT_APP_MEILI_SERVER_ADDRESS=http://YOUR_STATIC_IP:7700 yarn build
    npx serve build
    ```

    Replace `YOUR_STATIC_IP` with the actual static IP from `terraform output`

The dashboard will be served on a dynamically assigned port (typically `http://localhost:3000` or similar). Check the terminal output for the exact URL.

## 🗂️ Project Structure

```
.
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Variable definitions
├── startup.sh             # VM startup script
├── deploy-meilisearch.sh   # Automated deployment script
├── .gitignore             # Git ignore rules
└── README.md              # This file
```

## 🧹 Cleanup

To destroy the infrastructure:

```bash
terraform destroy -var="project_id=YOUR_PROJECT_ID"
```

## 🔧 Troubleshooting

### Common Issues

1. **Permission denied errors**:

    - Ensure you're authenticated: `gcloud auth list`
    - Check project permissions: `gcloud projects get-iam-policy PROJECT_ID`

2. **API not enabled errors**:

    ```bash
    gcloud services enable compute.googleapis.com
    gcloud services enable cloudresourcemanager.googleapis.com
    ```

3. **MeiliSearch not accessible**:
    - Check firewall rules in GCP Console
    - Verify the VM is running: `gcloud compute instances list`
    - Check startup script logs: `gcloud compute instances get-serial-port-output meilisearch-vm`

### Logs

To check MeiliSearch logs:

```bash
# SSH into the VM
gcloud compute ssh meilisearch-vm --zone=us-central1-a

# Check Docker logs
sudo docker logs meilisearch
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🔗 Resources

-   [MeiliSearch Documentation](https://docs.meilisearch.com/)
-   [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
-   [Google Cloud Documentation](https://cloud.google.com/docs)

---

**Note**: This configuration is suitable for development and testing. For production use, consider additional security measures, monitoring, and backup strategies.
