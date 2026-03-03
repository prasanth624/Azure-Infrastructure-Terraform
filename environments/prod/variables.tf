# ──────────────────────────────────────
# General
# ──────────────────────────────────────
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

# ──────────────────────────────────────
# Network
# ──────────────────────────────────────
variable "vnet_address_space" {
  description = "Address space for the VNet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_prefix" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private_subnet_prefix" {
  type    = string
  default = "10.0.2.0/24"
}

variable "allowed_ssh_cidrs" {
  description = "CIDRs allowed to SSH into VMs"
  type        = list(string)
  default     = []
}

# ──────────────────────────────────────
# Compute
# ──────────────────────────────────────
variable "vm_count" {
  description = "Number of VMs"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "VM SKU size"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "VM admin username"
  type        = string
  default     = "azureadmin"
}

variable "admin_ssh_public_key" {
  description = "SSH public key (leave empty to auto-generate)"
  type        = string
  default     = ""
}

# ──────────────────────────────────────
# Storage
# ──────────────────────────────────────
variable "storage_replication_type" {
  description = "Storage replication type"
  type        = string
  default     = "LRS"
}

variable "blob_containers" {
  description = "Blob containers to create"
  type        = list(string)
  default     = ["data", "logs", "backups"]
}

variable "file_shares" {
  description = "File shares to create (name => quota in GB)"
  type        = map(number)
  default     = {}
}
