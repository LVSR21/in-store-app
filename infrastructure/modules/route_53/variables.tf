variable "project_name" {
  type        = string
}

variable "environment" {
  type        = string
}

variable "domain_name" {
  type        = string
}

variable "aws_us_east_1" {
  type        = string
}


# --------------------------------------------------
# MODULES OUTPUTS VARIABLES
# --------------------------------------------------

# --------------------------------------------------
# ALB Module outputs
# --------------------------------------------------
variable "alb_dns_name" {
  description = "ALB DNS name."
  type = string
}

variable "alb_zone_id" {
  description = "ALB Zone ID."
  type = string
}

variable "alb_certificate_domain_validation_options" {
  description = "ALB Certificate Domain Validation Options."
  type = list(object({
    domain_name         = string
    resource_record_name = string
    resource_record_value = string
    resource_record_type = string
  }))
}

# --------------------------------------------------
# CloudFront Module outputs
# --------------------------------------------------
variable "cloudfront_domain_name" {
  description = "The domain name of the AWS CloudFront distribution, used for serving content through the CDN."
  type = string
}

variable "cloudfront_hosted_zone_id" {
  description = "The Route 53 hosted zone ID for the AWS CloudFront distribution, used to create DNS records pointing to the distribution."
  type = string
}