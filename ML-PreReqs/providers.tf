terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.75.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }

  }
  # Visual Studio subscription ID
  subscription_id = "1a5b78aa-7eb5-4f21-a55a-f736258d2dd9"
}