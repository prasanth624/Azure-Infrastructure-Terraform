# ──────────────────────────────────────
# Dev Environment Configuration
# ──────────────────────────────────────
project_name = "myapp"
environment  = "dev"
location     = "East US"

# Network
vnet_address_space    = "10.0.0.0/16"
public_subnet_prefix  = "10.0.1.0/24"
private_subnet_prefix = "10.0.2.0/24"
allowed_ssh_cidrs     = ["0.0.0.0/0"]  

# Compute
vm_count             = 1
vm_size              = "Standard_B2s"
admin_username       = "azureadmin"
admin_ssh_public_key = ""    # Leave empty to auto-generate

# Storage
storage_replication_type = "LRS"
blob_containers          = ["data", "logs", "backups"]
file_shares = {
  "appdata"   = 50
  "sharedata" = 100
}
