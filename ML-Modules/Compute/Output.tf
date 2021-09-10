output "vm-name" {
    value = azurerm_windows_virtual_machine.vm-compute.name
}
output "vm-private-ip" {
    value = azurerm_network_interface.nic-compute.private_ip_address
}
output "vmnic-id" {
    value = azurerm_network_interface.nic-compute.id
}
output "vm-id" {
    value = azurerm_windows_virtual_machine.vm-compute.id
}

output "nsg-name" {
    value = azurerm_network_security_group.nsg-compute.name
}
output "nsg-id" {
    value = azurerm_network_security_group.nsg-compute.id
}
