terraform {
  backend "azurerm" {
    resource_group_name  = "Terra-rg"
    storage_account_name = "remotesa01smdiyc0z"
    container_name       = "tfstate"
    key                  = "mattest.tfstate"
  }
}