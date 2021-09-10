# Peer Front End Vnet to Back End Vnet
resource "azurerm_virtual_network_peering" "peer-fe-be" {
  name                      = "vnetpeering-fe-be"
  resource_group_name       = azurerm_resource_group.rg-fe.name
  virtual_network_name      = azurerm_virtual_network.vnet-fe.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-be.id
}

resource "azurerm_virtual_network_peering" "peer-be-fe" {
  name                      = "vnetpeering-be-fe"
  resource_group_name       = azurerm_resource_group.rg-be.name
  virtual_network_name      = azurerm_virtual_network.vnet-be.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-fe.id
}

resource "azurerm_network_security_rule" "nsgrule-jbox-Be" {
  name                        = "nsg Rule to allow inbound rdp from Jbox"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "${module.jbox-compute.vm-private-ip}/32"
  destination_address_prefix  = "${module.webvm-compute.vm-private-ip}/32"
  resource_group_name         = azurerm_resource_group.rg-jbox.name
  network_security_group_name = module.jbox-compute.nsg-name
}

resource "azurerm_firewall_nat_rule_collection" "azfw-natrule" {
  name                = "NatRuleCollection-01"
  azure_firewall_name = azurerm_firewall.azfw-fe.name
  resource_group_name = azurerm_resource_group.rg-fe.name
  priority            = 100
  action              = "Dnat"
  rule {
    name = "webServer-rule-Port-80"
    source_addresses = [
      "*",
    ]
    destination_ports = [
      "80",
    ]
    destination_addresses = [
      azurerm_public_ip.pip-azfw.ip_address
    ]
    translated_port    = 80
    translated_address = module.webvm-compute.vm-private-ip
    protocols = [
      "TCP",
    ]
  }
  rule {
    name = "jbox-rule-Port-3389"
    source_addresses = [
      "*",
    ]
    destination_ports = [
      "3389",
    ]
    destination_addresses = [
      azurerm_public_ip.pip-azfw.ip_address
    ]
    translated_port    = 3389
    translated_address = module.jbox-compute.vm-private-ip
    protocols = [
      "TCP",
    ]
  }
}