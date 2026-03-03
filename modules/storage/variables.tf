variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be Standard or Premium."
  }
}

variable "replication_type" {
  description = "Storage replication type"
  type        = string
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.replication_type)
    error_message = "Invalid replication type."
  }
}

variable "access_tier" {
  description = "Access tier for BlobStorage/StorageV2"
  type        = string
  default     = "Hot"
}

variable "blob_containers" {
  description = "List of blob container names to create"
  type        = list(string)
  default     = []
}

variable "file_shares" {
  description = "Map of file share names to quota (GB)"
  type        = map(number)
  default     = {}
}

variable "enable_versioning" {
  description = "Enable blob versioning"
  type        = bool
  default     = true
}

variable "blob_soft_delete_days" {
  description = "Days to retain soft-deleted blobs"
  type        = number
  default     = 7
}

variable "container_soft_delete_days" {
  description = "Days to retain soft-deleted containers"
  type        = number
  default     = 7
}

variable "enable_lifecycle_policy" {
  description = "Enable lifecycle management policy"
  type        = bool
  default     = false
}

variable "enable_network_rules" {
  description = "Enable storage firewall/network rules"
  type        = bool
  default     = false
}

variable "allowed_ip_ranges" {
  description = "List of public IP ranges allowed access"
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "List of subnet IDs allowed access"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
