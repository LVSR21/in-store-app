####################################################
# Data source to get the zone id of the domain
####################################################
data "cloudflare_zone" "domain" {
    zone = "in-store-app.co.uk"
}

####################################################
# Configure Zone SSL Settings
####################################################
resource "cloudflare_zone_settings_override" "ssl_settings" {
  zone_id = data.cloudflare_zone.domain.id
  
  settings {
    ssl = "full"  # Options are: "off", "flexible", "full", "strict" --> recommended "full" for ALB with valid SSL certificate (which I will create below)
  }
}

####################################################
# DNS record for the root domain
####################################################
resource "cloudflare_record" "apex" {
  zone_id = data.cloudflare_zone.domain.id
  name = "@"     # @ represents the root domain in Cloudflare
  type = "CNAME"
  content = var.alb_dns_name
  proxied = true # Enable Cloudflare proxy (orange cloud)
  ttl = 1        # When proxied = true, the ttl is ignored but still needs to be set
}

####################################################
# DNS record for the www subdomain
####################################################
resource "cloudflare_record" "www" {
  zone_id = data.cloudflare_zone.domain.id
  name = "www"      # this handles the www subdomain
  type = "CNAME"
  content = var.alb_dns_name
  proxied = true    # Enable Cloudflare proxy (orange cloud)
  ttl = 1           # When proxied = true, the ttl is ignored but still needs to be set
}

####################################################
# Create a SSL/TLS certificate for the domain
####################################################
resource "aws_acm_certificate" "in_store_app_cert" {
  domain_name = "in-store-app.co.uk"
  validation_method = "DNS"

  # Allows the cert created above to be applied to any subdomains, such as www.example.com
  subject_alternative_names = [
    "*.in-store-app.co.uk" # Replace with my domain
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-certificate"
  }
}

####################################################
# Cloudflare DNS Validation Records
####################################################
resource "cloudflare_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.in_store_app_cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      type    = dvo.resource_record_type
      content = dvo.resource_record_value
      zone_id = data.cloudflare_zone.domain.id
    }
  }

  zone_id = each.value.zone_id
  name = each.value.name
  type = each.value.type
  content = each.value.content
  ttl = 1
}

####################################################
# Wait for Certificate to be Validated
####################################################
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn = aws_acm_certificate.in_store_app_cert.arn
  validation_record_fqdns = [for record in cloudflare_record.cert_validation : record.fqdn]

  depends_on = [
    cloudflare_record.cert_validation
  ]

  timeouts {
    create = "5m"
  }
}