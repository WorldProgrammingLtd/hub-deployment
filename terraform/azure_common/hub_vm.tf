resource "azurerm_network_security_group" "hub" {
  name                = "${var.prefix}-hub"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  tags                = var.tags

  # SSH access for setup
  security_rule {
    name                         = "ssh"
    description                  = "SSH from host"
    priority                     = 200
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "22"
    source_address_prefix        = ""
    source_address_prefixes      = split(",", var.setup_from_address_range)
    destination_address_prefix   = "*"
    destination_address_prefixes = []
  }

  security_rule {
    name                         = "nomadrpc"
    description                  = "Nomad RPC"
    priority                     = 210
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "4647"
    source_address_prefix        = ""
    source_address_prefixes      = azurerm_virtual_network.vn.address_space
    destination_address_prefix   = "*"
    destination_address_prefixes = []
  }

  security_rule {
    name                         = "http"
    description                  = "Ingress HTTP"
    priority                     = 220
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "9090"
    source_address_prefix        = ""
    source_address_prefixes      = azurerm_virtual_network.vn.address_space
    destination_address_prefix   = "*"
    destination_address_prefixes = []
  }

  security_rule {
    name                         = "hub"
    description                  = "Ingress internal"
    priority                     = 230
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "9091"
    source_address_prefix        = ""
    source_address_prefixes      = azurerm_virtual_network.vn.address_space
    destination_address_prefix   = "*"
    destination_address_prefixes = []
  }

  security_rule {
    name                         = "careg"
    description                  = "Worker CA service registration"
    priority                     = 240
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "9093"
    source_address_prefix        = ""
    source_address_prefixes      = azurerm_virtual_network.vn.address_space
    destination_address_prefix   = "*"
    destination_address_prefixes = []
  }

  security_rule {
    name                                       = "BlockRemoteAccess"
    description                                = ""
    priority                                   = 300
    direction                                  = "Inbound"
    access                                     = "Deny"
    protocol                                   = "Tcp"
    source_port_range                          = "*"
    destination_port_ranges                    = [
        "22",
        "3389",
    ]
    destination_address_prefix                 = "*"
    destination_address_prefixes               = []
    source_address_prefix                      = "Internet"
    source_address_prefixes                    = []
    source_application_security_group_ids      = []
  }

  # outbound internet access
  security_rule {
    name                         = "outbound"
    description                  = "Allow all outbound"
    priority                     = 100
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "*"
    source_address_prefix        = "*"
    source_address_prefixes      = []
    destination_address_prefix   = "*"
    destination_address_prefixes = []
  }
}

# Create public IP
resource "azurerm_public_ip" "hub-public-ip" {
  name                = "${var.prefix}-hub-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Create network interface
resource "azurerm_network_interface" "hub-nic" {
  name                      = "${var.prefix}-hub-nic"
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  tags                      = var.tags

  ip_configuration {
    name                          = "${var.prefix}-hub-nic-conf"
    subnet_id                     = azurerm_subnet.vms.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.hub-public-ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "hub-nsg" {
  network_interface_id          = azurerm_network_interface.hub-nic.id
  network_security_group_id = azurerm_network_security_group.hub.id
}

# Create Hub VM
resource "azurerm_linux_virtual_machine" "hub" {
  name                  = "${var.prefix}-hub"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.hub-nic.id]
  size                  = "${var.hubvmsize}"
  tags                  = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "almalinux"
    offer     = "almalinux"
    sku       = "8-gen2"
    version   = "latest"
  }

  plan {
    name = "8-gen2"
    product = "almalinux"
    publisher = "almalinux"
  }

  computer_name  = "${var.prefix}-hub"
  admin_username = var.ssh_user_name

  admin_ssh_key {
    username   = var.ssh_user_name
    public_key = azurerm_ssh_public_key.common-auth.public_key
  }
}

