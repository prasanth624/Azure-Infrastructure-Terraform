terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "yourterraformstate"      # CHANGE THIS
    container_name       = "tfstate"
    key                  = "dev/terraform.tfstate"
  }
}
