resource "azurerm_resource_group" "rg-jbox" {
  name     = "rg-jobx-${var.prefix}"
  location = var.location
  tags     = var.tags
}


# Create NIC for jboxVM
resource "azurerm_network_interface" "nic-jbox" {
  name                = "nic-jbox${var.prefix}"
  location            = azurerm_resource_group.rg-jbox.location
  resource_group_name = azurerm_resource_group.rg-jbox.name

  ip_configuration {
    name                          = "nic-jbox-ipconfig-${var.prefix}"
    subnet_id                     = azurerm_subnet.snet-jbox.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create NSG
resource "azurerm_network_security_group" "nsg-jbox" {
  name                = "nsg-jbox-${var.prefix}"
  location            = azurerm_resource_group.rg-jbox.location
  resource_group_name = azurerm_resource_group.rg-jbox.name
  tags                = var.tags
}

# Create NSG Rule
resource "azurerm_network_security_rule" "nsgrule-jbox" {
  name                        = "Allow_Inbound_Port_3389"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "${azurerm_network_interface.nic-jbox.private_ip_address}/32"
  resource_group_name         = azurerm_resource_group.rg-jbox.name
  network_security_group_name = azurerm_network_security_group.nsg-jbox.name
}

#Associate NSG to jbox NIC
resource "azurerm_network_interface_security_group_association" "nsg-nicjbox" {
  network_interface_id      = azurerm_network_interface.nic-jbox.id
  network_security_group_id = azurerm_network_security_group.nsg-jbox.id
}

# Create jbox Server VM
resource "azurerm_windows_virtual_machine" "vm-jbox" {
  name                     = var.jboxvm-name
  location                 = azurerm_resource_group.rg-jbox.location
  resource_group_name      = azurerm_resource_group.rg-jbox.name
  size                     = "Standard_B2s"
  admin_username           = var.admin-username
  admin_password           = var.admin-password
  network_interface_ids    = [azurerm_network_interface.nic-jbox.id]
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
resource "azurerm_virtual_machine_extension" "extension-jboxvm" {
  name                 = "iis-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm-jbox.id
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