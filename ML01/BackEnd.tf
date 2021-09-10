resource "azurerm_resource_group" "rg-be" {
  name     = "${var.be-rg-name}-${var.prefix}"
  location = var.location
  tags     = var.tags
}

# Create VNET
resource "azurerm_virtual_network" "vnet-be" {
  name                = "vnet-be-${var.prefix}"
  location            = azurerm_resource_group.rg-be.location
  resource_group_name = azurerm_resource_group.rg-be.name
  address_space       = ["30.0.0.0/16"]
  dns_servers         = ["168.63.129.16", "8.8.8.8"]
  tags                = var.tags

}

#Create BackEnd Subnet 
resource "azurerm_subnet" "snet-be-web" {
  name                 = "snet-be-web-${var.prefix}"
  resource_group_name  = azurerm_resource_group.rg-be.name
  virtual_network_name = azurerm_virtual_network.vnet-be.name
  address_prefixes     = ["30.0.2.0/24"]
}

# Create NIC for WebVM
resource "azurerm_network_interface" "nic-web" {
  name                = "nic-web${var.prefix}"
  location            = azurerm_resource_group.rg-be.location
  resource_group_name = azurerm_resource_group.rg-be.name

  ip_configuration {
    name                          = "nic-web-ipconfig-${var.prefix}"
    subnet_id                     = azurerm_subnet.snet-be-web.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create NSG
resource "azurerm_network_security_group" "nsg-web" {
  name                = "nsgweb-${var.prefix}"
  location            = azurerm_resource_group.rg-be.location
  resource_group_name = azurerm_resource_group.rg-be.name
  tags                = var.tags
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
  destination_address_prefix  = "${azurerm_network_interface.nic-web.private_ip_address}/32"
  resource_group_name         = azurerm_resource_group.rg-be.name
  network_security_group_name = azurerm_network_security_group.nsg-web.name
}

#Associate NSG to Web NIC
resource "azurerm_network_interface_security_group_association" "nsg-nicweb" {
  network_interface_id      = azurerm_network_interface.nic-web.id
  network_security_group_id = azurerm_network_security_group.nsg-web.id
}

# Create Web Server VM
resource "azurerm_windows_virtual_machine" "vm-web" {
  name                     = var.webvm-name
  location                 = azurerm_resource_group.rg-be.location
  resource_group_name      = azurerm_resource_group.rg-be.name
  size                     = "Standard_B2s"
  admin_username           = var.admin-username
  admin_password           = var.admin-password
  network_interface_ids    = [azurerm_network_interface.nic-web.id]
  enable_automatic_updates = true
  provision_vm_agent       = true
  tags                     = var.tags


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-smalldisk"
    version   = "latest"
  }
}

# Install Extensions into VM
resource "azurerm_virtual_machine_extension" "extension-webvm" {
  name                 = "iis-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm-web.id
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

