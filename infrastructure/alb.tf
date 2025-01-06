###################################################################################################################
## Create Application Load Balancer in public subnets with HTTP default listener that redirects traffic to HTTPS ##
###################################################################################################################

resource "aws_alb" "alb" {
  name            = "${var.namespace}-ALB-${var.environment}" # Name of the ALB
  security_groups = [aws_security_group.alb.id]               # Security group for the ALB
  subnets         = aws_subnet.public.*.id                    # Public subnets for the ALB

  tags = {
    Scenario = var.scenario                                   
  }
}


#######################################################################################
## Default HTTPS listener that blocks all traffic without valid custom origin header ##
#######################################################################################

resource "aws_alb_listener" "alb_default_listener_https" {
  load_balancer_arn = aws_alb.alb.arn                         # ARN (Amazon Resource Name) of the ALB
  port              = 443                                     # HTTPS port
  protocol          = "HTTPS"                                 # HTTPS listener
  certificate_arn   = aws_acm_certificate.alb_certificate.arn # Certificate for the ALB
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06" # SSL policy for the ALB

  default_action {                                            # Default action for the listener
    type = "fixed-response"                                   # Fixed response whenever incoming traffic does not match any listener rules in the ALB

    fixed_response {                                          # Fixed response configuration
      content_type = "text/plain"                             # Content type of the response
      message_body = "Access denied"                          # Message body of the response
      status_code  = "403"                                    # Status code of the response
    }
  }

  tags = {
    Scenario = var.scenario
  }

  depends_on = [  
    aws_acm_certificate.alb_certificate,            # Make sure the certificate is created before creating the listener
    aws_acm_certificate_validation.alb_certificate  # Make sure the certificate is validated before creating the listener
    ]          
}


########################################################################################################
## HTTPS Listener Rule to only allow traffic with a valid custom origin header coming from CloudFront ##
########################################################################################################

resource "aws_alb_listener_rule" "https_listener_rule" {
  listener_arn = aws_alb_listener.alb_default_listener_https.arn                            # ARN of the HTTPS listener

  action {                                                                                  # Action to take when the rule is matched
    type             = "forward"                                                            # Forward the request to the ALB target group
    target_group_arn = aws_alb_target_group.service_target_group.arn                        # ARN of the target group
  }

  condition {                                                                               # Condition to check if the request has a valid custom origin header
    host_header {                                                                           # Checks the HTTP host header of the incoming request
      values = [var.domain_name]                                                            # The domain name of the application
    }
  }

  condition {                                                                               # Condition to check if the request has a valid custom origin header
    http_header {                                                                           # Checks the HTTP header of the incoming request
      http_header_name = "X-Custom-Header"                                                  # The name of the custom header
      values           = [data.aws_secretsmanager_secret_version.cloudfront.secret_string]  # The value of the custom header - please note because I need the actual secret value to set it as custom header I need to use '.secret_string' to directly access the secret value stored in AWS Secrets Manager.
    }
  }

  tags = {
    Scenario = var.scenario
  }
}


############################################################
## Target Group for the services/instances behind the ALB ##
############################################################

resource "aws_alb_target_group" "service_target_group" {
  name                 = "${var.namespace}-TargetGroup-${var.environment}"  # Name of the target group
  port                 = 80                                                 # Port of the target group
  protocol             = "HTTP"                                             # Protocol of the target group
  vpc_id               = aws_vpc.default.id                                 # VPC ID (identifier)
  deregistration_delay = 5                                                  # Deregistration delay for the target group

  health_check {                                                            # Health check configuration for the target group
    healthy_threshold   = 2                                                 # Number of consecutive successful health checks before the target is considered healthy
    unhealthy_threshold = 2                                                 # Number of consecutive failed health checks before the target is considered unhealthy
    interval            = 60                                                # Interval between health checks (in seconds) - 60 seconds = 1 minute
    matcher             = var.healthcheck_matcher                           # Matcher for the health check
    path                = var.healthcheck_endpoint                          # Endpoint for the health check
    port                = "traffic-port"                                    # Port for the health check
    protocol            = "HTTP"                                            # Protocol for the health check
    timeout             = 30                                                # Timeout for the health check
  }

  depends_on = [aws_alb.alb]                                                # Make sure the ALB is created before the target group

  tags = {
    Scenario = var.scenario
  }
}



# ------------------------- EXPLANATION ------------------------- #
# Application Load Balancer (ALB) is part of the Amazon Elastic Load Balancing service and takes over the task of load balancing (e.g. simultaneously distributing incoming application traffic across multiple targets, such as ECS EC2 instances) from the user.
# ALB runs in the public subnets.
# ALB is a highly available component and redundant due to the multiple AZs setup.
# ALB receives incoming traffic via ALB Listeners (e.,g HTTPS Listener that can only accept traffic on port 443).