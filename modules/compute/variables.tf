#--------------------------------------------------------------
# COMPUTE MODULE
# Creates: Public IPs, NICs, Availability Set, Linux VMs
#--------------------------------------------------------------

# ──────────────────────────────────────
# SSH Key (generated or provided)
# ──────────────────────────────────────
resource "tls_private_key" "ssh" {
  count     = var.admin_ssh_public_key == "" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

locals {
  ssh_public_key = var.admin_ssh_public_key != "" ? var.admin_ssh_public_key : tls_private_key.ssh[0].public_key_openssh
}

# ──────────────────────────────────────
# Public IPs for VMs
# ──────────────────────────────────────
resource "azurerm_public_ip" "vm" {
  count               = var.assign_public_ip ? var.vm_count : 0
  name                = "${var.project_name}-${var.environment}-vm-${count.index}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

# ──────────────────────────────────────
# Network Interfaces
# ──────────────────────────────────────
resource "azurerm_network_interface" "vm" {
  count               = var.vm_count
  name                = "${var.project_name}-${var.environment}-vm-${count.index}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.assign_public_ip ? azurerm_public_ip.vm[count.index].id : null
  }

  tags = var.tags
}

# ──────────────────────────────────────
# Availability Set
# ──────────────────────────────────────
resource "azurerm_availability_set" "main" {
  count                        = var.vm_count > 1 ? 1 : 0
  name                         = "${var.project_name}-${var.environment}-avset"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true

  tags = var.tags
}

# ──────────────────────────────────────
# Linux Virtual Machines
# ──────────────────────────────────────
resource "azurerm_linux_virtual_machine" "main" {
  count               = var.vm_count
  name                = "${var.project_name}-${var.environment}-vm-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username

  availability_set_id = var.vm_count > 1 ? azurerm_availability_set.main[0].id : null

  network_interface_ids = [
    azurerm_network_interface.vm[count.index].id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = local.ssh_public_key
  }

  os_disk {
    name                 = "${var.project_name}-${var.environment}-vm-${count.index}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.vm_image.publisher
    offer     = var.vm_image.offer
    sku       = var.vm_image.sku
    version   = var.vm_image.version
  }

  # Cloud-init / custom data
  custom_data = var.custom_data != "" ? base64encode(var.custom_data) : null

  # Boot diagnostics
  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_uri
  }

  tags = var.tags
}

# ──────────────────────────────────────
# Managed Data Disks (optional)
# ──────────────────────────────────────
resource "azurerm_managed_disk" "data" {
  count                = var.data_disk_size_gb > 0 ? var.vm_count : 0
  name                 = "${var.project_name}-${var.environment}-vm-${count.index}-datadisk"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.data_disk_type
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  count              = var.data_disk_size_gb > 0 ? var.vm_count : 0
  managed_disk_id    = azurerm_managed_disk.data[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.main[count.index].id
  lun                = 0
  caching            = "ReadWrite"
}
