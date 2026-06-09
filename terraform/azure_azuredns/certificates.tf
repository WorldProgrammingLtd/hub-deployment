# This verifies ownership through AzureDNS using LetsEncrypt.
# Other DNS providers are available and could be swapped in

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

# Creates an account on the ACME server using the private key and an email
resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = var.acme_email
}

# Gets a certificate from the ACME server
resource "acme_certificate" "hub" {
  common_name              = "hub.${var.prefix}.${var.dns_zone}"

  account_key_pem          = acme_registration.reg.account_key_pem
  certificate_p12_password = var.acme_cert_password

  # Azure DNS refuses non-recursive (RD=0) queries from arbitrary IPs, which
  # is what LEGO uses for its authoritative propagation check. Disabling the
  # authoritative check and using a public recursive resolver instead routes
  # the check through RD=1 queries that Azure accepts from known resolvers.
  disable_complete_propagation = true
  recursive_nameservers        = ["8.8.8.8:53", "1.1.1.1:53"]

  depends_on = [azurerm_dns_zone.zone]

  dns_challenge {
    provider = "azuredns"
    config = {
      AZURE_RESOURCE_GROUP = azurerm_resource_group.rg.name
      AZURE_ZONE_NAME      = var.dns_zone
      AZURE_TTL            = 300
    }
  }
}

resource "azurerm_dns_zone" "zone" {
  name                = var.dns_zone
  resource_group_name = azurerm_resource_group.rg.name
}

