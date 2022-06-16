# This generates records in cloudflare. Other DNS providers could be substituted.

resource "aws_route53_record" "lb" {
  zone_id = aws_route53_zone.hub.zone_id
  ttl  = 300
  name = "${aws_acm_certificate.lb.domain_name}"
  records = ["${aws_lb.hublb.dns_name}"]
  type = "CNAME"
}

resource "aws_route53_record" "hub" {
  zone_id = aws_route53_zone.hub.zone_id
  ttl  = 300
  name = "hubvm.hub-${var.prefix}.${var.dns_zone}"
  records = ["${aws_instance.hub.private_ip}"]
  type = "A"
}

resource "aws_route53_record" "worker" {
  count = var.worker_vm_count
  ttl  = 300
  zone_id = aws_route53_zone.hub.zone_id
  name = "worker${count.index}.hub-${var.prefix}.${var.dns_zone}"
  records = ["${aws_instance.worker[count.index].private_ip}"]
  type = "A"
}
