resource "azurerm_storage_account" "hubdata" {
  name                     = "${replace(var.prefix, "/[^a-zA-Z0-9]/", "")}hubdata"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_storage_account_network_rules" "hubdata" {
  storage_account_id = azurerm_storage_account.hubdata.id

  default_action             = "Deny"
  ip_rules                   = split(",", var.setup_from_address_range)
  virtual_network_subnet_ids = [azurerm_subnet.vms.id]
}

resource "azurerm_storage_container" "hubdata" {
  name                  = "${var.prefix}-hubdata"
  storage_account_name  = azurerm_storage_account.hubdata.name
  container_access_type = "private"
}

# For managing Lets Encrypt cert renewals:
resource "azurerm_storage_account" "certdata" {
  name                     = "${replace(var.prefix, "/[^a-zA-Z0-9]/", "")}certdata"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_storage_container" "certdata" {
  name                  = "public"
  storage_account_name  = azurerm_storage_account.certdata.name
  container_access_type = "blob"
}

