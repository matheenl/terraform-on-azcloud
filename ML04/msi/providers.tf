terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.75.0"
    }

  }
  # If using remote state, add back end block
  backend "azurerm" {
    # The below parameters can be removed from here and saved into backend.tfvars file and run terraform init -backend-config=backend.tfvars
    #resource_group_name  = "rg-prereqs-Terra"
    #storage_account_name = "satfstatewcgl"
    #container_name       = "tfstate"
    #key                  = "ML02.tfstate"
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }

  }
  
}