output "fw_public_ip" {
    value = azurerm_public_ip.pip-azfw.ip_address
}