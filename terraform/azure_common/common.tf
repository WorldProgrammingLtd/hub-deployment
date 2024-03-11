resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}"
  location = "${var.region}"
  tags     = var.tags
}

resource "azurerm_virtual_network" "vn" {
  name                = "${var.prefix}-vm-sub"
  address_space       = ["172.17.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_subnet" "lb" {
  name                 = "${var.prefix}-lb"
  address_prefixes     = ["172.17.10.0/24"]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
}

resource "azurerm_subnet" "vms" {
  name                 = "${var.prefix}-vms"
  address_prefixes     = ["172.17.20.0/24"]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "hubdb" {
  name                 = "${var.prefix}-hubdb"
  address_prefixes     = ["172.17.30.0/24"]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  # Flexible PostgreSQL requirements:
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_ssh_public_key" "common-auth" {
  name                = "auth-${var.prefix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  public_key          = "${var.ssh_public_key}"
  tags                = var.tags
}

