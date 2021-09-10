
# Create Resource Group
resource "azurerm_resource_group" "rg-fe" {
  name     = "${var.prefix}-${var.env}-RG-FE"
  location = var.location
  tags     = var.tags
}

# Remote Module
module "vnet-fe" {
  source              = "Azure/vnet/azurerm"
  resource_group_name = azurerm_resource_group.rg-fe.name
  vnet_name           = "${var.prefix}-${var.env}-vnet-fe"
  address_space       = ["20.0.0.0/16"]
  subnet_names        = ["AzureFirewallSubnet", "${var.prefix}-${var.env}-snet-fe-jbox"]
  subnet_prefixes     = ["20.0.2.0/24", "20.0.1.0/24"]
  dns_servers         = ["168.63.129.16", "8.8.8.8"]
  tags                = var.tags
  depends_on          = [azurerm_resource_group.rg-fe]
}

/*
# Create VNET
resource "azurerm_virtual_network" "vnet-fe" {
  name                = "${var.prefix}-${var.env}-vnet-fe"
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
  name                 = "${var.prefix}-${var.env}-snet-jbox-"
  resource_group_name  = azurerm_resource_group.rg-fe.name
  virtual_network_name = azurerm_virtual_network.vnet-fe.name
  address_prefixes     = ["20.0.2.0/24"]
}
*/

# Create Public IP for Azure Firewall
resource "azurerm_public_ip" "pip-azfw" {
  name                = "${var.prefix}-${var.env}-pip-AzFw${var.prefix}"
  resource_group_name = azurerm_resource_group.rg-fe.name
  location            = azurerm_resource_group.rg-fe.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Create Azure Firewall
resource "azurerm_firewall" "azfw-fe" {
  name                = "${var.prefix}-${var.env}-azfw-fe-${var.prefix}"
  location            = azurerm_resource_group.rg-fe.location
  resource_group_name = azurerm_resource_group.rg-fe.name

  ip_configuration {
    name = "${var.prefix}-${var.env}-azfw-fe-ipconfig-${var.prefix}"
    #subnet_id            = azurerm_subnet.example.id
    subnet_id            = module.vnet-fe.vnet_subnets[0]
    public_ip_address_id = azurerm_public_ip.pip-azfw.id
  }
}