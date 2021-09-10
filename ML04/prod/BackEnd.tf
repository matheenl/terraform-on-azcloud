resource "azurerm_resource_group" "rg-be" {
  name     = "${var.prefix}-${var.env}-RG-BE"
  location = var.location
  tags     = var.tags
}

module "vnet-be" {
  source              = "Azure/vnet/azurerm"
  resource_group_name = azurerm_resource_group.rg-be.name
  vnet_name           = "${var.prefix}-${var.env}-vnet-be"
  address_space       = ["30.0.0.0/16"]
  subnet_names        = ["${var.prefix}-${var.env}-snet-be-web01", "${var.prefix}-${var.env}-snet-be-web02"]
  subnet_prefixes     = ["30.0.2.0/24", "30.0.1.0/24"]
  dns_servers         = ["168.63.129.16", "8.8.8.8"]
  tags                = var.tags
  depends_on          = [azurerm_resource_group.rg-be]
}

/*
# Create VNET
resource "azurerm_virtual_network" "vnet-be" {
  name                = "${var.prefix}-${var.env}-vnet-be"
  location            = azurerm_resource_group.rg-be.location
  resource_group_name = azurerm_resource_group.rg-be.name
  address_space       = ["30.0.0.0/16"]
  dns_servers         = ["168.63.129.16", "8.8.8.8"]
  tags                = var.tags

}

#Create BackEnd Subnet 
resource "azurerm_subnet" "snet-be-web" {
  name                 = "${var.prefix}-${var.env}-snet-be-web"
  resource_group_name  = azurerm_resource_group.rg-be.name
  virtual_network_name = azurerm_virtual_network.vnet-be.name
  address_prefixes     = ["30.0.2.0/24"]
}
*/

module "webvm-compute" {
  source         = "../../ML-Modules/Compute"
  rg-location    = azurerm_resource_group.rg-be.location
  rg-name        = azurerm_resource_group.rg-be.name
  subnet-id      = module.vnet-be.vnet_subnets[0]
  vm-name        = "${var.prefix}-${var.env}-vmweb"
  tags           = var.tags
  admin-username = var.admin-username
  admin-password = var.admin-password
  vm-size        = var.vm-size[0]
  vm-image       = var.vm-image
  depends_on          = [
    azurerm_resource_group.rg-be,
    module.vnet-be    
    ]
}

# Create NSG Rule
resource "azurerm_network_security_rule" "nsgrule-web" {
  name                        = "Allow_Inbound_Port80"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "${module.webvm-compute.vm-private-ip}/32"
  resource_group_name         = azurerm_resource_group.rg-be.name
  network_security_group_name = module.webvm-compute.nsg-name
}

#Associate NSG to Web NIC
resource "azurerm_network_interface_security_group_association" "nsg-nicweb" {
  network_interface_id      = module.webvm-compute.vmnic-id
  network_security_group_id = module.webvm-compute.nsg-id
}


# Install Extensions into VM
resource "azurerm_virtual_machine_extension" "extension-webvm" {
  name                 = "iis-extension"
  virtual_machine_id   = module.webvm-compute.vm-id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  tags                 = var.tags
  settings             = <<SETTINGS
    {
        "commandToExecute": "powershell Install-WindowsFeature -name Web-Server -IncludeManagementTools;"
    }
SETTINGS
}

