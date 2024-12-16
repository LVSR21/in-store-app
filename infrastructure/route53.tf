# Fetch the existing hosted zone
data "aws_route53_zone" "primary" {
  name = "in-store-app.co.uk."
}

# Alias record pointing to CloudFront
resource "aws_route53_record" "cloudfront_alias" {
  name    = var.domain_name
  zone_id = data.aws_route53_zone.primary.zone_id
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.default.domain_name
    zone_id                = aws_cloudfront_distribution.default.hosted_zone_id
    evaluate_target_health = false
  }
}