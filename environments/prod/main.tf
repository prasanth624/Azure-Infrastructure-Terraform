#--------------------------------------------------------------
# DEV ENVIRONMENT — Orchestrates all modules
#--------------------------------------------------------------

locals {
  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    CreatedAt   = timestamp()
  }
}

# ──────────────────────────────────────
# Resource Group
# ──────────────────────────────────────
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location
  tags     = local.tags
}

# ──────────────────────────────────────
# Network Module
# ──────────────────────────────────────
module "network" {
  source = "../../modules/network"

  project_name          = var.project_name
  environment           = var.environment
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  vnet_address_space    = var.vnet_address_space
  public_subnet_prefix  = var.public_subnet_prefix
  private_subnet_prefix = var.private_subnet_prefix
  allowed_ssh_cidrs     = var.allowed_ssh_cidrs
  enable_nat_gateway    = false

  tags = local.tags
}

# ──────────────────────────────────────
# Storage Module
# ──────────────────────────────────────
module "storage" {
  source = "../../modules/storage"

  project_name     = var.project_name
  environment      = var.environment
  location         = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  replication_type = var.storage_replication_type
  blob_containers  = var.blob_containers
  file_shares      = var.file_shares

  enable_versioning       = true
  enable_lifecycle_policy = true
  enable_network_rules    = true
  allowed_subnet_ids      = [module.network.private_subnet_id]

  tags = local.tags
}

# ──────────────────────────────────────
# Compute Module
# ──────────────────────────────────────
module "compute" {
  source = "../../modules/compute"

  project_name         = var.project_name
  environment          = var.environment
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  subnet_id            = module.network.public_subnet_id
  vm_count             = var.vm_count
  vm_size              = var.vm_size
  admin_username       = var.admin_username
  admin_ssh_public_key = var.admin_ssh_public_key
  assign_public_ip     = true
  os_disk_type         = "Standard_LRS"
  os_disk_size_gb      = 30
  data_disk_size_gb    = 32
  data_disk_type       = "StandardSSD_LRS"

  boot_diagnostics_storage_uri = module.storage.primary_blob_endpoint

  custom_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>Hello from $(hostname)</h1>" > /var/www/html/index.html
  EOF

  tags = local.tags
}
