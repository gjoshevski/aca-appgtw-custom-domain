locals {
  subnets = cidrsubnets(var.cidr, 4, 4)
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.cidr]
}

resource "azurerm_subnet" "appgtw" {
  name                 = "appgtw-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.subnets[0]]
}

resource "azurerm_subnet" "aca" {
  name                 = "aca-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.subnets[1]]
}