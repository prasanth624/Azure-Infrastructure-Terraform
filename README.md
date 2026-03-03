### Azure Infrastructure - Terraform

Deploys Azure infrastructure using reusable Terraform modules.

### What It Creates

- **Network** — VNet, Public/Private Subnets, NSGs
- **Compute** — Linux VMs with SSH access, Data Disks
- **Storage** — Storage Account, Blob Containers, File Shares

### Project Structure

```
├── modules/
│   ├── network/
│   ├── compute/
│   └── storage/
├── environments/
│   ├── dev/
│___└── prod/

```

### Quick Start

```bash
az login
cd environments/dev
terraform init
terraform plan
terraform apply
```

### Clean Up

```bash
terraform destroy
```

### Requirements

- Terraform >= 1.5
- Azure CLI
- Azure Subscription
