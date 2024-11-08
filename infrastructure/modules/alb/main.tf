####################################################
# Application Load Balancer
####################################################
resource "aws_lb" "alb" {
  name               = "${var.project_name}-${var.environment}-alb"
  security_groups    = [var.alb_security_group_id]
  subnets            = tolist(var.public_subnet_ids)

  tags = {
    Name = "${var.project_name}-${var.environment}-alb"
  }
}

#########################################################################
# ALB HTTPS Listener
# ---------------------------
# HTTPS listener blocks all traffic without valid custom origin header
#########################################################################
resource "aws_lb_listener" "alb_listener_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.alb_certificate.arn
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"

  default_action {
    type             = "fixed-response"
    
    fixed_response {
      content_type = "text/plain"
      message_body = "Access Denied"
      status_code  = "403"
    }
  }

  depends_on = [aws_acm_certificate.alb_certificate]

  tags = {
    Name = "${var.project_name}-${var.environment}-alb-listener-https"
  }
}

#########################################################################################################
# ALB Listener Rule
# ---------------------------
# ALB Listener Rule to only allow traffic with a valid custom origin header coming from the CloudFront
#########################################################################################################
resource "aws_alb_listener_rule" "https_listener_rule" {
  listener_arn = aws_alb_listener.alb_listener_https.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }

  condition {
    host_header {
      values = ["${var.environment}.${var.domain_name}"]
    }
  }

  condition {
    http_header {
      http_header_name = "X-CloudFront-Access-Key"
      values           = [var.cloudfront_origin_secret]
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-https-listener-rule"
  }
}

####################################################
# ALB Target Group
####################################################
resource "aws_lb_target_group" "alb_target_group" {
  name                 = "${var.project_name}-${var.environment}-alb-target-group"
  port                 = "80"
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 120

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    interval            = "60"
    path                = "/"
    timeout             = 30
    matcher             = 200
    protocol            = "HTTP"
  }

  depends_on = [aws_lb.alb]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-alb-target-group"
  }
}

##########################################################
# ACM Certificate for ALB
##########################################################
resource "aws_acm_certificate" "alb_certificate" {
  domain_name = var.domain_name
  validation_method = "DNS"
  subject_alternative_names = ["*.${var.domain_name}"]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-alb-certificate"
  }
}

##########################################################
# ACM Certificate Validation for ALB
##########################################################
resource "aws_acm_certificate_validation" "alb_certificate" {
  certificate_arn = aws_acm_certificate.alb_certificate.arn
  validation_record_fqdns = [for record in var.certificate_validation_records : record.fqdn]
}