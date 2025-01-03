###########################################
## Create WAF (Web Application Firewall) ##
###########################################

resource "aws_wafv2_web_acl" "cloudfront_waf" {
  name        = "${var.namespace}-waf-${var.environment}" # Name of the WAF Web ACL
  description = "WAF Web ACL with security rules"         # Description of the WAF Web ACL
  provider    = aws.us_east_1                             # AWS provider region
  scope       = "CLOUDFRONT"                              # The scope of the WebACL, which indicates the type of web requests that it can inspect

  default_action {                                        # The action to take when a web request doesn't match any of the rules in the WebACL
    allow {}                                              # Allow the request to be forwarded to the origin
  }

  rule {                                                  # Rule to define the rate limit - this helps my application from DDoS attacks, brute force attempts, excessive crawling and API abuse.
    name     = "RateLimit"                                # Name of the rule
    priority = 1                                          # Priority of the rule - the 'priority' argument determines the order in which WAF rules and rule groups are evaluated and applied to incoming web requests. The rule with the lowest numeric priority is at the top of the list, and the rule with the highest numeric priority is at the bottom.

    action {                                              # The action to take when a web request matches the rule
      block {}                                            # Blocks requests that exceed the limit
    }

    statement {                                           # The rule statement defines the criteria for the rule, including the match conditions, the action to take if a web request matches the conditions, and the visibility settings for the rule.
      rate_based_statement {                              # Rate-based rule statement to define the rate limit
        limit              = 2000                         # Maximum requests allowed
        aggregate_key_type = "IP"                         # Tracks requests per IP address
      }
    }

    visibility_config {                                   # The visibility settings for the rule, which determines whether it's enabled and whether it's associated with a metric or a sampled request.
      cloudwatch_metrics_enabled = true                   # Enable CloudWatch metrics
      metric_name                = "RateLimitRule"        # Name of the CloudWatch metric
      sampled_requests_enabled   = true                   # Enable sampling of requests
    }
  }

  rule {                                                  # Rule to enable AWS Common Rule Set Key protections - this include XSS (cross-site scripting) patterns, SQL injection patterns, HTTP protocol violations, invalid requests, known malicious user-agents, protocol exploits, and more.
    name     = "AWSCommonRules"                           # Name of the rule
    priority = 2                                          # Priority of the rule

    override_action {                                     # The action to take when a web request matches the rule
      none {}                                             # Uses AWS default actions for rules
    }

    statement {                                           # The rule statement defines the criteria for the rule, including the match conditions, the action to take if a web request matches the conditions, and the visibility settings for the rule.
      managed_rule_group_statement {                      # Managed rule group statement to define the rule
        name        = "AWSManagedRulesCommonRuleSet"      # Name of the managed rule group
        vendor_name = "AWS"                               # Vendor name of the managed rule group
      }
    }

    visibility_config {                                   # The visibility settings for the rule, which determines whether it's enabled and whether it's associated with a metric or a sampled request.
      cloudwatch_metrics_enabled = true                   # Enable CloudWatch metrics
      metric_name                = "AWSCommonRules"       # Name of the CloudWatch metric
      sampled_requests_enabled   = true                   # Enable sampling of requests
    }
  }

  rule {                                                # Rule to enable SQL Injection Protection - this rule set helps protect against SQL injection attacks by inspecting query strings and blocking requests that contain malicious SQL code.
    name     = "SQLiProtection"                         # Name of the rule
    priority = 3                                        # Priority of the rule

    override_action {                                   # The action to take when a web request matches the rule
      none {}                                           # Uses AWS default actions for rules
    } 

    statement {                                         # The rule statement defines the criteria for the rule, including the match conditions, the action to take if a web request matches the conditions, and the visibility settings for the rule.
      managed_rule_group_statement {                    # Managed rule group statement to define the rule
        name        = "AWSManagedRulesSQLiRuleSet"      # Name of the managed rule group
        vendor_name = "AWS"                             # Vendor name of the managed rule group
      }
    }

    visibility_config {                                 # The visibility settings for the rule, which determines whether it's enabled and whether it's associated with a metric or a sampled request.
      cloudwatch_metrics_enabled = true                 # Enable CloudWatch metrics
      metric_name                = "SQLiProtection"     # Name of the CloudWatch metric
      sampled_requests_enabled   = true                 # Enable sampling of requests
    }
  }

  rule {                                                # Rule to enable XSS (Cross-Site Scripting) Protection - this rule set helps protect against cross-site scripting attacks by inspecting query strings and blocking requests that contain malicious scripts.
    name     = "XSSProtection"                          # Name of the rule
    priority = 4                                        # Priority of the rule

    override_action {                                   # The action to take when a web request matches the rule
      none {}                                           # Uses AWS default actions for rules
    } 

    statement {                                               # The rule statement defines the criteria for the rule, including the match conditions, the action to take if a web request matches the conditions, and the visibility settings for the rule.
      managed_rule_group_statement {                          # Managed rule group statement to define the rule
        name        = "AWSManagedRulesKnownBadInputsRuleSet"  # Name of the managed rule group
        vendor_name = "AWS"                                   # Vendor name of the managed rule group
      }
    }

    visibility_config {                                 # The visibility settings for the rule, which determines whether it's enabled and whether it's associated with a metric or a sampled request.
      cloudwatch_metrics_enabled = true                 # Enable CloudWatch metrics
      metric_name                = "XSSProtection"      # Name of the CloudWatch metric
      sampled_requests_enabled   = true                 # Enable sampling of requests
    }
  }

  rule {                                              # Rule to enable IP Reputation List - this rule blocks requests from IP addresses known for malicious activities. Blocks IPs associated with known botnets, malware distribution, command & control servers, brute force attacks, cryptocurrency mining and anonymous proxy services.
    name     = "IPReputation"                         # Name of the rule
    priority = 5                                      # Priority of the rule

    override_action {                                 # The action to take when a web request matches the rule
      none {}                                         # Uses AWS default actions for rules
    }

    statement {                                               # The rule statement defines the criteria for the rule, including the match conditions, the action to take if a web request matches the conditions, and the visibility settings for the rule.
      managed_rule_group_statement {                          # Managed rule group statement to define the rule
        name        = "AWSManagedRulesAmazonIpReputationList" # Name of the managed rule group
        vendor_name = "AWS"                                   # Vendor name of the managed rule group
      }
    }

    visibility_config {                               # The visibility settings for the rule, which determines whether it's enabled and whether it's associated with a metric or a sampled request.
      cloudwatch_metrics_enabled = true               # Enable CloudWatch metrics
      metric_name                = "IPReputation"     # Name of the CloudWatch metric
      sampled_requests_enabled   = true               # Enable sampling of requests
    }
  }

  visibility_config {                                                       # The visibility settings for the WebACL, which determines whether it's enabled and whether it's associated with a metric or a sampled request.
    cloudwatch_metrics_enabled = true                                       # Enable CloudWatch metrics
    metric_name                = "${var.namespace}-waf-${var.environment}"  # Name of the CloudWatch metric
    sampled_requests_enabled   = true                                       # Enable sampling of requests
  }

  tags = {
    Environment = var.environment
    Namespace   = var.namespace
  }
}



#------------------------- EXPLANATION -------------------------#
# WAF (Web Application Firewall) is a security service that helps protect web applications from common web exploits that could affect application availability, compromise security, or consume excessive resources. 
# WAF gives control over how traffic reaches the applications by enabling the creation of security rules that block common attack patterns, such as SQL injection or cross-site scripting, and rules that filter out specific traffic patterns defined.
# WAF sits in front of the web application and acts as a shield between the web application and the internet.
# WAF filters and monitors HTTP/HTTPS traffic.