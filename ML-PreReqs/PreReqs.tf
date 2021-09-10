# This file will create Storage Account to store State Files and Key Vault to save
resource "random_string" "random" {
  length           = 4
  special          = false
  lower            = true
  upper            = false
  number           = true
  override_special = "/@£$"
}
variable "prefix" {
  type = string
  description = "Prefix for all resources"
  default = "Terra"
}
resource "azurerm_resource_group" "rg-prereqs" {
  name     = "rg-prereqs-${var.prefix}"
  location = "WestEurope"
  tags     = {
    Learning     = "TF-Exam"
    Cost         = "Free"
    Subscription = "VisualStudio Enterprise MSDN"}
}

data "azurerm_client_config" "current" {}
resource "azurerm_key_vault" "kv" {
  name                        = "kv-${var.prefix}-${random_string.random.id}"
  location                    = azurerm_resource_group.rg-prereqs.location
  resource_group_name         = azurerm_resource_group.rg-prereqs.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      
      "Backup", "Delete",  "Get", "List", "Purge", "Recover", "Restore", 
    ]

    secret_permissions = [
      "Backup", "Delete",  "Get", "List", "Purge", "Recover", "Restore", 
    ]

    storage_permissions = [
      "get", "list", "purge", "delete", 
    ]
  }
}

resource "azurerm_storage_account" "sa-tfstate" {
  name                     = "satfstate${random_string.random.id}"
  location                 = azurerm_resource_group.rg-prereqs.location
  resource_group_name      = azurerm_resource_group.rg-prereqs.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    Learning     = "TF-Exam"
    Cost         = "Free"
    Subscription = "VisualStudio Enterprise MSDN"}
}