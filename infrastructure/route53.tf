################################################
##  Fetch the existing hosted zone on Route53 ##
################################################

data "aws_route53_zone" "primary" {
  name = "in-store-app.co.uk."  # The name of the hosted zone
}


##########################################################
## Create a Route53 alias record pointing to CloudFront ##
##########################################################

resource "aws_route53_record" "cloudfront_alias" {
  name    = var.domain_name                       # The name of the record
  zone_id = data.aws_route53_zone.primary.zone_id # The ID of the hosted zone
  type    = "A"                                   # The type of the record in this case an A record - an A (Address) record is one of the most fundamental DNS record types that maps a domain name directly to an IPv4 address, creates a direct pointer between a domain name and the server's IP address and enables browsers to find the correct server when users enter my domain name.

  alias {                                                                         # An alias block is used to create an alias record. Alias records are used to map a domain to an AWS resource.
    name                   = aws_cloudfront_distribution.default.domain_name      # The name of the resource to which the alias record should point in this case the domain name of the CloudFront distribution
    zone_id                = aws_cloudfront_distribution.default.hosted_zone_id   # The hosted zone ID of the resource to which the alias record should point in this case the hosted zone ID of the CloudFront distribution
    evaluate_target_health = false                                                # Whether or not Route 53 should evaluate the health of the target resource in this is 'false' because CloudFront itself provides automatic failover and high availability and do not support native health checks like other AWS services. CloudFront automatically routes requests to healthy edge locations. If an edge locations becomes unhealthy CloudFront stops routing requests to it.
  }
}



#------------------------- EXPLANATION -------------------------#
# Route 53 is AWS's Domain Name System (DNS) web service.
# Route 53 serves three main purposes: Domain registration, DNS routing, and Health checking.
# Route 53 translates human-readable domain names into IP addresses, manages traffic routing globally, connects user requests to AWS resources (like CloudFront) and provides high availability and low latency.
# In my case whenever users visit my domain, Route 53 directs them to my CloudFront CDN.
# In my case Route 53 also manages my domain 'in-store-app.co.uk' and enables my web application to be accessible via a user friendly domain name instead of CloudFront default domain.