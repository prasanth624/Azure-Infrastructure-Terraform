#--------------------------------------------------------------
# STORAGE MODULE
# Creates: Storage Account, Containers, File Shares, Lifecycle
#--------------------------------------------------------------

# ──────────────────────────────────────
# Random suffix for globally unique name
# ──────────────────────────────────────
resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

locals {
  # Storage account name: 3-24 chars, lowercase letters and numbers only
  storage_account_name = "${lower(var.project_name)}${var.environment}${random_string.storage_suffix.result}"
}

# ──────────────────────────────────────
# Storage Account
# ──────────────────────────────────────
resource "azurerm_storage_account" "main" {
  name                     = local.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.replication_type
  account_kind             = "StorageV2"
  access_tier              = var.access_tier

  # Security
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  https_traffic_only_enabled      = true

  # Network rules
  dynamic "network_rules" {
    for_each = var.enable_network_rules ? [1] : []
    content {
      default_action             = "Deny"
      ip_rules                   = var.allowed_ip_ranges
      virtual_network_subnet_ids = var.allowed_subnet_ids
      bypass                     = ["AzureServices"]
    }
  }

  # Blob properties
  blob_properties {
    versioning_enabled = var.enable_versioning

    delete_retention_policy {
      days = var.blob_soft_delete_days
    }

    container_delete_retention_policy {
      days = var.container_soft_delete_days
    }
  }

  tags = var.tags
}

# ──────────────────────────────────────
# Blob Containers
# ──────────────────────────────────────
resource "azurerm_storage_container" "containers" {
  for_each              = toset(var.blob_containers)
  name                  = each.value
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

# ──────────────────────────────────────
# File Shares
# ──────────────────────────────────────
resource "azurerm_storage_share" "shares" {
  for_each             = var.file_shares
  name                 = each.key
  storage_account_id   = azurerm_storage_account.main.id
  quota                = each.value   # in GB
}

# ──────────────────────────────────────
# Lifecycle Management Policy
# ──────────────────────────────────────
resource "azurerm_storage_management_policy" "lifecycle" {
  count              = var.enable_lifecycle_policy ? 1 : 0
  storage_account_id = azurerm_storage_account.main.id

  rule {
    name    = "move-to-cool"
    enabled = true
    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["logs/"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 30
        tier_to_archive_after_days_since_modification_greater_than = 90
        delete_after_days_since_modification_greater_than          = 365
      }
      snapshot {
        delete_after_days_since_creation_greater_than = 30
      }
    }
  }

  rule {
    name    = "cleanup-old-versions"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      version {
        delete_after_days_since_creation = 90
      }
    }
  }
}
