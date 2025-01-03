################################
## Create Certificate for ALB ##
################################

resource "aws_acm_certificate" "alb_certificate" {
  domain_name               = var.domain_name           # Domain name for which the certificate should be issued
  validation_method         = "DNS"                     # DNS (Domain Name System) validation method
  subject_alternative_names = ["*.${var.domain_name}"]  # Wildcard certificate for subdomains - this means that the certificate is valid for all subdomains of the domain name

  tags = {
    Scenario = "${var.scenario}-alb"
  }
}


#########################################################################
## Validate the ALB certificate by creating a CNAME record in Route 53 ##
#########################################################################

resource "aws_acm_certificate_validation" "alb_certificate" {
  certificate_arn         = aws_acm_certificate.alb_certificate.arn                   # ARN of the certificate to validate
  validation_record_fqdns = [aws_route53_record.generic_certificate_validation.fqdn]  # CNAME record for DNS validation - here the CNAME record is used for SSL/TLS certificate validation.
}


########################################################################
## Create Certificate for CloudFront Distribution in region us.east-1 ##
########################################################################

resource "aws_acm_certificate" "cloudfront_certificate" {
  provider                  = aws.us_east_1             # Provider for the certificate (CloudFront only supports certificates in the us-east-1 region)
  domain_name               = var.domain_name           # Domain name for which the certificate should be issued
  validation_method         = "DNS"                     # DNS (Domain Name System) validation method
  subject_alternative_names = ["*.${var.domain_name}"]  # Wildcard certificate for subdomains

  tags = {
    Scenario = "${var.scenario}-cloudfront"
  }
}


#################################################################################
## Validate the CloudFront certificate by creating a CNAME record in Route 53 ##
#################################################################################
resource "aws_acm_certificate_validation" "cloudfront_certificate" {
  provider                = aws.us_east_1                                             # Provider for the certificate validation (CloudFront only supports certificates in the us-east-1 region)
  certificate_arn         = aws_acm_certificate.cloudfront_certificate.arn            # ARN of the certificate to validate
  validation_record_fqdns = [aws_route53_record.generic_certificate_validation.fqdn]  # CNAME record for DNS validation
}


##########################################################################################
## DNS validation record for both certificates, as records are the same for all regions ##
##########################################################################################

resource "aws_route53_record" "generic_certificate_validation" {
  name    = tolist(aws_acm_certificate.alb_certificate.domain_validation_options)[0].resource_record_name     # Name of the DNS record
  type    = tolist(aws_acm_certificate.alb_certificate.domain_validation_options)[0].resource_record_type     # Type of the DNS record
  records = [tolist(aws_acm_certificate.alb_certificate.domain_validation_options)[0].resource_record_value]  # Value of the CNAME record
  zone_id = data.aws_route53_zone.primary.zone_id                                                             # ID of the hosted zone
  ttl     = 300                                                                                               # Time to live for the record (300 seconds = 5 minutes)
}



#------------------------- EXPLANATION -------------------------#
# Digital Certificates are electronic documents that verify the identity of a website or server (validates website ownership, shows visitors the site is legitimate and its required for e-commerce and sensitive data handling).
# Digital Certificates provide a digital signature that ensures the authenticity of the website and enable encrypted connections (encrypts data in transit between client and server, prevents main-in-the-middle attacks and enables HTTPS connections).
# Domain Name System (DNS) is a hierarchical naming system that translates human-readable domain names to IP addresses. It acts like the internet's phone book.
# DNS validation for ACM (Amazon Certificate Manager) certificates provides domain ownership by having specific DNS records. It's an automated, more convenient and more secure than email-based validation. Allow automatic certificate renewal.
# CNAME (Canonical Name) it's a type of DNS record that maps one domain name (an alias) to another domain name (the canonical name). It's like a domain name forwarding service.