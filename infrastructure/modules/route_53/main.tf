#############################################################################################################################################
# Primary Route 53 DNS Hosted Zone for the domain
# --------------------------------------------------------------
# The data soource pulls my Hosted Zone ID from Route 53, this allows me to run 'terraform destroy' without deleting the Hosted Zone.
# This also includes NS records in the top level domain.
#############################################################################################################################################
data "aws_route53_zone" "primary" {
  zone_id = "Z0424262FAPMZ7KJ2ASZ"
}

##########################################################
# Route 53 Record for the apex domain
# ---------------------------------------
# Point A record to CloudFront distribution
##########################################################
resource "aws_route53_record" "apex" {
  name = var.domain_name
  type = "A"
  zone_id = data.aws_route53_zone.primary.zone_id

  alias {
    name = var.cloudfront_domain_name
    zone_id = var.cloudfront_hosted_zone_id
    evaluate_target_health = false # Route 53 will route traffic to the CloudFront distribution without checking its health status, allowing CloudFront to handle any potential failover needs internally.
  }
}

##########################################################
# Route 53 Record for the www subdomain
##########################################################
resource "awz_route53_record" "www" {
  name = "www.${var.domain_name}"
  zone_id = data.aws_route53_zone.primary.zone_id
  type = "CNAME"
  records = ["${var.alb_dns_name}"]
  ttl = "5"
}

########################################################################################################################################################
# Route 53 Certificate Validation Records
# -----------------------------------------------
# Please note that I only need one record for the DNS validation for both certificates (ALB and CloudFront), as records are the same for all regions.
########################################################################################################################################################
resource "aws_route53_record" "certificate_validation_records" {
  for_each = {
    for dvo in var.alb_certificate_domain_validation_options : dvo.var.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.primary.zone_id
}