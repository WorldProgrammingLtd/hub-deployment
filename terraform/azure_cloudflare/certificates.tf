# This verifies ownership through cloudflare using LetsEncrypt.
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
  certificate_p12_password = "${var.acme_cert_password}"

  dns_challenge {
    provider = "cloudflare"
    config = {
      CF_DNS_API_TOKEN  = "${var.cloudflare_api_token}"
    }
  }
}

data "cloudflare_zone" "zone" {
  name = var.dns_zone
}

