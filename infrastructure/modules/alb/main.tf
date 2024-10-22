####################################################
# Application Load Balancer
####################################################
resource "aws_lb" "alb" {
  internal           = var.load_balancer_internal
  load_balancer_type = var.load_balancer_type
  security_groups    = [var.alb_security_group_id]
  subnets            = tolist(var.public_subnets)

  tags = {
    Name = "${var.project_name}-alb"
  }
}

####################################################
# ALB HTTP istener
####################################################
resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Name = "${var.project_name}-alb-listener-http"
  }
}

####################################################
# ALB HTTPS Listener
####################################################
resource "aws_lb_listener" "alb_listener_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }

  tags = {
    Name = "${var.project_name}-alb-listener-https"
  }
}


####################################################
# ALB Target Group
####################################################
resource "aws_lb_target_group" "alb_target_group" {
  target_type = "instance"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    interval            = "60"
    path                = "/"
    timeout             = 30
    matcher             = 200
    protocol            = "HTTP"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-alb-target-group"
  }
}