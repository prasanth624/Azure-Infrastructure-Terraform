# ──────────────────────────────────────
# Network Outputs
# ──────────────────────────────────────
output "vnet_id" {
  description = "Virtual Network ID"
  value       = module.network.vnet_id
}

output "public_subnet_id" {
  value = module.network.public_subnet_id
}

output "private_subnet_id" {
  value = module.network.private_subnet_id
}

# ──────────────────────────────────────
# Compute Outputs
# ──────────────────────────────────────
output "vm_names" {
  description = "VM names"
  value       = module.compute.vm_names
}

output "vm_public_ips" {
  description = "VM public IPs"
  value       = module.compute.vm_public_ips
}

output "vm_private_ips" {
  description = "VM private IPs"
  value       = module.compute.vm_private_ips
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = length(module.compute.vm_public_ips) > 0 ? "ssh ${module.compute.vm_admin_username}@${module.compute.vm_public_ips[0]}" : "No public IP assigned"
}

output "generated_ssh_private_key" {
  description = "Auto-generated SSH private key (save to file)"
  value       = module.compute.generated_ssh_private_key
  sensitive   = true
}

# ──────────────────────────────────────
# Storage Outputs
# ──────────────────────────────────────
output "storage_account_name" {
  description = "Storage account name"
  value       = module.storage.storage_account_name
}

output "storage_primary_blob_endpoint" {
  description = "Primary blob endpoint"
  value       = module.storage.primary_blob_endpoint
}
