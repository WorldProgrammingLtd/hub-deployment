# This verifies ownership through cloudflare. Other DNS providers are available and
# could be swapped in

resource "aws_acm_certificate" "lb" {
  domain_name       = "hub.hub-${var.prefix}.${var.dns_zone}"
  validation_method = "DNS"
}

data "aws_route53_zone" "dev" {
  name         = "navops-devel.grid.org"
  private_zone = false
}

resource "aws_route53_zone" "hub" {
  name = "hub-${var.prefix}.navops-devel.grid.org"

  tags = {
    Environment = "hub-${var.prefix}"
  }
}

resource "aws_route53_record" "hub-ns" {
  zone_id = data.aws_route53_zone.dev.zone_id
  name    = aws_route53_zone.hub.name
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.hub.name_servers
}

resource "aws_route53_record" "lb_validate" {
  for_each = {
    for dvo in aws_acm_certificate.lb.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.hub.zone_id
}

resource "aws_acm_certificate_validation" "lb" {
  certificate_arn         = aws_acm_certificate.lb.arn
  validation_record_fqdns = [for record in aws_route53_record.lb_validate : record.fqdn]
}
