
output "user_mi_serviceprincipal_id" {
value= azurerm_user_assigned_identity.user-mi.principal_id
}
output "user_mi_user_id" {
value= azurerm_user_assigned_identity.user-mi.id
}

output "current_subscription_display_name" {
  value = data.azurerm_subscription.current.display_name
}