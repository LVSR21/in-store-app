resource "aws_wafv2_web_acl" "cloudfront_waf" {
  name        = "${var.namespace}-waf-${var.environment}"
  description = "WAF Web ACL with security rules"
  provider    = aws.us_east_1
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # Rate limiting rule helps my application from DDoS attacks, brute force attempts, excessive crawling and API abuse.
  rule {
    name     = "RateLimit"
    priority = 1

    action {
      block {} # Blocks requests that exceed the limit
    }

    statement {
      rate_based_statement {
        limit              = 2000 # Maximum requests allowed
        aggregate_key_type = "IP" # Tracks requests per IP address
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }
  }

  # AWS Common Rule Set key protections include XSS (cross-site scripting) patterns, SQL injection patterns, HTTP protocol violations, invalid requests, known malicious user-agents, protocol exploits
  rule {
    name     = "AWSCommonRules"
    priority = 2

    override_action {
      none {} # Uses AWS default actions for rules
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSCommonRules"
      sampled_requests_enabled   = true
    }
  }

  # SQL Injection Protection
  rule {
    name     = "SQLiProtection"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLiProtection"
      sampled_requests_enabled   = true
    }
  }

  # XSS Protection
  rule {
    name     = "XSSProtection"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "XSSProtection"
      sampled_requests_enabled   = true
    }
  }

  # IP Reputation List blocks requests from IP addresses known for malicious activities. Blocks IPs associated with known botnets, malware distribution, command & control servers, brute force attacks, cryptocurrency mining and anonymous proxy services.
  rule {
    name     = "IPReputation"
    priority = 5

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IPReputation"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.namespace}-waf-${var.environment}"
    sampled_requests_enabled   = true
  }

  tags = {
    Environment = var.environment
    Namespace   = var.namespace
  }
}

# Note: The 'priority' argument determines the order in which WAF rules and rule groups are evaluated and applied to incoming web requests. The rule with the lowest numeric priority is at the top of the list, and the rule with the highest numeric priority is at the bottom.