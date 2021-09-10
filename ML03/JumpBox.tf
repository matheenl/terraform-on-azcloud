resource "azurerm_resource_group" "rg-jbox" {
  name     = "${var.prefix}-${var.env}-RG-JBOX"
  location = var.location
  tags     = var.tags
}

# Using local Module to Create NIC, NSG and VM
module "jbox-compute" {
  source         = "../ML-Modules/Compute"
  rg-location    = azurerm_resource_group.rg-jbox.location
  rg-name        = azurerm_resource_group.rg-jbox.name
  subnet-id      = module.vnet-be.vnet_subnets[1] # [0] is Azure Firewall subnet
  vm-name        = "${var.prefix}-${var.env}-vmjbox"
  tags           = var.tags
  admin-username = var.admin-username
  admin-password = var.admin-password
  vm-size        = var.vm-size[0]
  vm-image       = var.vm-image
   depends_on          = [
    azurerm_resource_group.rg-fe,
    module.vnet-fe    
    ]
}

# Create NSG Rule
resource "azurerm_network_security_rule" "nsgrule-jbox" {
  name                        = "${var.prefix}-${var.env}-Allow_Inbound_Port_3389 From any"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "${module.jbox-compute.vm-private-ip}/32"
  resource_group_name         = azurerm_resource_group.rg-jbox.name
  network_security_group_name = module.jbox-compute.nsg-name
}

#Associate NSG to jbox NIC
resource "azurerm_network_interface_security_group_association" "nsg-nicjbox" {
  network_interface_id      = module.jbox-compute.vmnic-id
  network_security_group_id = module.jbox-compute.nsg-id
}

# Install Extensions into VM
resource "azurerm_virtual_machine_extension" "extension-jboxvm" {
  name                 = "${var.prefix}-${var.env}-iis-extension"
  virtual_machine_id   = module.jbox-compute.vm-id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  tags                 = var.tags
  settings             = <<SETTINGS
    {
        "commandToExecute": "powershell Install-WindowsFeature -name Telnet-Client,Web-Server -IncludeManagementTools;"
    }
SETTINGS
}