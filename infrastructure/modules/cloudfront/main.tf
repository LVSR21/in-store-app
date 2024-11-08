##########################################################
# CloudFront Distribution
##########################################################
resource "aws_cloudfront_distribution" "cloudfront" {
  comment = "${var.project_name}-${var.environment}-cloudfront"
  enabled = true
  is_ipv6_enabled = true
  aliases = ["${var.environment}.${var.domain_name}"]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = var.alb_name
    viewer_protocol_policy = "redirect-to-https" # Redirect HTTP to HTTPS

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }
  }

  origin {
    domain_name = var.alb_dns_name
    origin_id   = var.alb_name

    custom_header {
      name  = "X-CloudFront-Access-Key"
      value = var.cloudfront_origin_secret
    }

    custom_origin_config {
      origin_read_timeout      = 60
      origin_keepalive_timeout = 60
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cloudfront_certificate.arn
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method       = "sni-only"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-cloudfront"
  }
}

##########################################################
# ACM Certificate for CloudFront
##########################################################
resource "aws_acm_certificate" "cloudfront_certificate" {
  provider = aws.us_east_1
  domain_name = var.domain_name
  validation_method = "DNS"
  subject_alternative_names = ["*.${var.domain_name}"]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-cloudfront-certificate"
  }
}

##########################################################
# ACM Certificate Validation for CloudFront
##########################################################
resource "aws_acm_certificate_validation" "cloudfront_certificate" {
  provider = aws.us_east_1
  certificate_arn = aws_acm_certificate.cloudfront_certificate.arn
  validation_record_fqdns = [for record in var.certificate_validation_records : record.fqdn]
}