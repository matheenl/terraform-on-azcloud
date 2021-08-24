data "azurerm_key_vault" "kv01" {
  name                = "TFKeyvaultsmdiyc0z"
  resource_group_name = "Terra-rg"
}

data "azurerm_key_vault_secret" "kv01" {
  name         = "admin-password"
  key_vault_id = data.azurerm_key_vault.kv01.id
}