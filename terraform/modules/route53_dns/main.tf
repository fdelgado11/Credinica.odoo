data "aws_route53_zone" "primary" {
  name         = var.route53_zone_name
  private_zone = false
}

resource "aws_route53_record" "subdomain" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.subdomain_name
  type    = "A"
  ttl     = 300
  records = [var.target_ip]
}
