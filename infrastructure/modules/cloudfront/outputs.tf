output "cloudfront_domain_name" {
    description = "The domain name of the AWS CloudFront distribution, used for serving content through the CDN."
    value = aws_cloudfront_distribution.cloudfront.domain_name
}

output "cloudfront_hosted_zone_id" {
    description = "The Route 53 hosted zone ID for the AWS CloudFront distribution, used to create DNS records pointing to the distribution."
    value = aws_cloudfront_distribution.cloudfront.hosted_zone_id
}