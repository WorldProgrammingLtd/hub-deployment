# This generates records in cloudflare. Other DNS providers could be substituted.

resource "cloudflare_record" "lb" {
  zone_id = data.cloudflare_zone.zone.id
  name = "hub.${var.prefix}.${var.dns_zone}"
  value = azurerm_public_ip.hublb-public-ip.ip_address
  type = "A"
}

resource "cloudflare_record" "hub" {
  zone_id = data.cloudflare_zone.zone.id
  name = "hubvm.${var.prefix}.${var.dns_zone}"
  value = "${azurerm_linux_virtual_machine.hub.private_ip_address}"
  type = "A"
}

resource "cloudflare_record" "worker" {
  count = var.worker_vm_count

  zone_id = data.cloudflare_zone.zone.id
  name = "worker${count.index}.${var.prefix}.${var.dns_zone}"
  value = "${azurerm_linux_virtual_machine.worker[count.index].private_ip_address}"
  type = "A"
}
