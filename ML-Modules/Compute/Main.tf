# Create NIC for WebVM
resource "azurerm_network_interface" "nic-compute" {
  name                = "nic-01${var.vm-name}"
  location            = var.rg-location
  resource_group_name = var.rg-name

  ip_configuration {
    name                          = "nic-ipconfig-${var.vm-name}"
    subnet_id                     = var.subnet-id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create NSG
resource "azurerm_network_security_group" "nsg-compute" {
  name                = "nsg-${var.vm-name}"
  location            = var.rg-location
  resource_group_name = var.rg-name
  tags                = var.tags
}

# Create Web Server VM
resource "azurerm_windows_virtual_machine" "vm-compute" {
  name                     = var.vm-name
  location                 = var.rg-location
  resource_group_name      = var.rg-name
  size                     = var.vm-size
  admin_username           = var.admin-username
  admin_password           = var.admin-password
  network_interface_ids    = [azurerm_network_interface.nic-compute.id]
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