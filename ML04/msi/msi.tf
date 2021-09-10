
data "azurerm_resource_group" "rg-terra" {
  name = "rg-prereqs-Terra"
  
}
resource "azurerm_user_assigned_identity" "user-mi" {
  resource_group_name = data.azurerm_resource_group.rg-terra.name
  location            = data.azurerm_resource_group.rg-terra.location
  name = "${var.prefix}-${var.env}-user-mi"
}

data "azurerm_subscription" "current" {}

data "azurerm_role_definition" "contributor" {
  name = "Contributor"
}

resource "azurerm_role_assignment" "role-assign" {
  #name               = "${var.prefix}-${var.env}-role-assign-user-mi"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.user-mi.principal_id
}

# resource "azurerm_role_assignment" "role-assign1" {
#   name               = "${var.prefix}-${var.env}-role-assign-user-mi"
#   scope              = data.azurerm_subscription.primary.id
#   role_definition_id = "${data.azurerm_subscription.subscription.id}${data.azurerm_role_definition.contributor.id}"
#   principal_id       = azurerm_virtual_machine.example.identity[0]["principal_id"]
# }