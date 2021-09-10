
# Create Resource Group
resource "azurerm_resource_group" "rg-fe" {
  name     = "rg-fe-${var.prefix}"
  location = var.location
  tags     = var.tags
}

# Create VNET
resource "azurerm_virtual_network" "vnet-fe" {
  name                = "vnet-fe-${var.prefix}"
  location            = azurerm_resource_group.rg-fe.location
  resource_group_name = azurerm_resource_group.rg-fe.name
  address_space       = ["20.0.0.0/16"]
  dns_servers         = ["168.63.129.16", "8.8.8.8"]
  tags                = var.tags

}

#Create Subnet for azure FW
resource "azurerm_subnet" "snet-fe-azfw" {
  name                 = "AzureFirewallSubnet" # Name should be exact to be used for Azure Firewall
  resource_group_name  = azurerm_resource_group.rg-fe.name
  virtual_network_name = azurerm_virtual_network.vnet-fe.name
  address_prefixes     = ["20.0.1.0/24"]
}

#Create Subnet for Jumpbox 
resource "azurerm_subnet" "snet-jbox" {
  name                 = "snet-jbox-${var.prefix}"
  resource_group_name  = azurerm_resource_group.rg-fe.name
  virtual_network_name = azurerm_virtual_network.vnet-fe.name
  address_prefixes     = ["20.0.2.0/24"]
}

# Create Public IP for Azure Firewall
resource "azurerm_public_ip" "pip-azfw" {
  name                = "pip-AzFw${var.prefix}"
  resource_group_name = azurerm_resource_group.rg-fe.name
  location            = azurerm_resource_group.rg-fe.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Create Azure Firewall
resource "azurerm_firewall" "azfw-fe" {
  name                = "azfw-fe-${var.prefix}"
  location            = azurerm_resource_group.rg-fe.location
  resource_group_name = azurerm_resource_group.rg-fe.name

  ip_configuration {
    name = "azfw-fe-ipconfig-${var.prefix}"
    #subnet_id            = azurerm_subnet.example.id
    subnet_id            = azurerm_subnet.snet-fe-azfw.id
    public_ip_address_id = azurerm_public_ip.pip-azfw.id
  }
}