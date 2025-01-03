####################################
## Create CloudFront Distribution ##
####################################

resource "aws_cloudfront_distribution" "default" {
  comment         = "${var.namespace} CloudFront Distribution"  # The comment that appears in the distribution configuration.
  enabled         = true                                        # Whether the distribution is enabled to accept end user requests for content. This means that CloudFront is active and serving content. Requests will be processes and cached at edge locations. Content will be distributed through the CDN network.
  is_ipv6_enabled = true                                        # Whether the IPv6 is enabled for the distribution.
  aliases         = [var.domain_name]                           # Extra CNAMEs (alternate domain names), if any, for this distribution.
  web_acl_id      = aws_wafv2_web_acl.cloudfront_waf.arn        # To associate with WAF (Web Application Firewall).

  default_cache_behavior {                                                                # The default cache behavior for this distribution.
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"] # The HTTP methods CloudFront processes and forwards to my custom origin (my ALB). GET to retrieve resources. HEAD to get headers only. OPTIONS to get supported methods. PUT to upload/update resources. POST to submit data. PATCH to partial updates. DELETE to remove resources.
    cached_methods         = ["GET", "HEAD", "OPTIONS"]                                   # The HTTP methods CloudFront caches responses to.
    target_origin_id       = aws_alb.alb.name                                             # The value of ID for the origin that I want CloudFront to route requests to when they use the default cache behavior.
    viewer_protocol_policy = "redirect-to-https"                                          # The protocol that viewers can use to access the files in the origin that I specified in TargetOriginId when a request matches this cache behavior.

    forwarded_values {      # The forwarded values configuration that specifies how CloudFront handles query strings, cookies and headers.
      query_string = true   # Whether CloudFront forwards query strings to the origin (ALB) that is associated with this cache behavior.
      headers      = ["*"]  # The headers that CloudFront forwards to the origin (LB) that is associated with this cache behavior. In this case it will forward all headers.

      cookies {           # The cookies configuration that specifies how CloudFront handles cookies.
        forward = "all"   # Whether CloudFront forwards cookies to the origin (ALB) that is associated with this cache behavior.
      }
    }
  }

  origin {                              # The origin configuration from which CloudFront gets my files when a viewer requests them.
    domain_name = aws_alb.alb.dns_name  # The DNS domain name of the origin that CloudFront sends requests to when a request matches this cache behavior.
    origin_id   = aws_alb.alb.name      # A unique identifier for the origin. The value of ID must be unique within the distribution.

    custom_header {                                                           # The custom header configuration that specifies the custom headers that CloudFront (CDN) forwards to the origin (ALB) that is associated with this cache behavior.
      name  = "X-Custom-Header"                                               # The name of the custom header that CloudFront forwards to the origin (ALB) that is associated with this cache behavior.
      value = data.aws_secretsmanager_secret_version.cloudfront.secret_string # The value for the custom header that CloudFront forwards to the origin (ALB) that is associated with this cache behavior. Because I need the actual secret value to set it as custom header I need to use '.secret_string' to directly access the secret value stored in AWS Secrets Manager.
    }

    custom_origin_config {                                        # The custom origin configuration that specifies how CloudFront sends requests to the origin (ALB) that is associated with this cache behavior.
      origin_read_timeout      = 60                               # The custom read timeout, in seconds (60 seconds = 1 minute), when CloudFront forwards requests to the origin (ALB) that is associated with this cache behavior. This means that CloudFront will wait for 60 seconds for the origin to respond before timing out.
      origin_keepalive_timeout = 60                               # The custom keep-alive timeout, in seconds, when CloudFront forwards requests to the origin (ALB) that is associated with this cache behavior. This means that CloudFront will keep the connection open for 60 seconds before closing it.
      http_port                = 80                               # The HTTP port that CloudFront uses to connect to the origin (ALB) that is associated with this cache behavior.
      https_port               = 443                              # The HTTPS port that CloudFront uses to connect to the origin (ALB) that is associated with this cache behavior.
      origin_protocol_policy   = "https-only"                     # The origin protocol policy that CloudFront uses when interacting with the origin (ALB) that is associated with this cache behavior.
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]  # The SSL/TLS protocols that CloudFront uses when communicating with the origin (ALB) that is associated with this cache behavior. TLSv1 and TLSv1.1 are legacy versions. TLSv1.2 is a more secure version.
    }
  }

  restrictions {                # The restriction configuration that specifies the restriction settings for the distribution.
    geo_restriction {           # The geo restriction configuration that specifies the countries in which CloudFront either allows or disallows distribution of content.
      restriction_type = "none" # The restriction type that specifies how CloudFront restricts distribution of my content by country. In this case I'm not restricting any country.
    }
  }

  viewer_certificate {                                                        # The viewer certificate configuration that specifies the SSL/TLS certificate that CloudFront uses for HTTPS connections.
    acm_certificate_arn      = aws_acm_certificate.cloudfront_certificate.arn # The ARN of the ACM certificate that CloudFront uses for HTTPS connections.
    minimum_protocol_version = "TLSv1.1_2016"                                 # The minimum version of the SSL/TLS protocol that CloudFront uses for HTTPS connections. TLSv1.1_2016 is a secure version.
    ssl_support_method       = "sni-only"                                     # The SSL support method that CloudFront uses to serve HTTPS requests. SNI (Server Name Indication) is a more modern method.
  }

  tags = {
    Name     = "${var.namespace}_CloudFront_${var.environment}"
    Scenario = var.scenario
  }
}


#------------------------- EXPLANATION -------------------------#
# CloudFront Distribution is a AWS's CDN (Content Deliver Network) service that distributes content globally, reduces latency for end users, provides security features and caches content at edge locations.
# CloudFront Distribution in my case provides AWS Shield (DDoS protection) enabled by default and AWS WAF (Web Application Firewall) to protect against common web exploits (e.g. SQL injections).