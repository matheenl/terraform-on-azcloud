terraform {
  backend "azurerm" {
    subscription_id      = "1a5b78aa-7eb5-4f21-a55a-f736258d2dd9"
    resource_group_name  = "Terra-rg"
    storage_account_name = "remotesa01smdiyc0z"
    container_name       = "tfstate"
    key                  = "Lab9.2.tfstate"
  }
}