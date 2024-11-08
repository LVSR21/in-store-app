####################################################
# Security Group for Bastion Host
####################################################
resource "aws_security_group" "bastion_security_group" {
  name          = "${var.project_name}-${var.environment}-bastion-sg"
  description   = "Bastion host Security Group."
  vpc_id        = var.vpc_id

  ingress {
    description = "Allows SSH access from VPN IP."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.open_vpn_ip] # My OpenVPN IP that limits access to the bastion host.
  }

  egress {
    description = "Restrict outboudb traffic to EC2 instances in private subnets."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.private_subnets_cidr_blocks ## These are the CIDR blocks of the private subnets so the Bastion Host can communicate with EC2 instances in private subnets.
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-bastion-sg"
  }
}

####################################################
# Security Group for EC2
####################################################
resource "aws_security_group" "ec2_security_group" {
  name              = "${var.project_name}-${var.environment}-ec2-sg"
  description       = "Security group for EC2 instances in ECS cluster."
  vpc_id            = var.vpc_id

  ingress {
    description     = "Allow ingress traffic from ALB on HTTP ports"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  ingress {
    description     = "Allow inbound traffic from ALB on HTTPS port."
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  ingress {
    description     = "Allow SSH inbound traffic from bastion host."
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_security_group.id]
  }

  egress {
    description     = "Allow outbound traffic to MongoDB."
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    cidr_blocks     = var.private_subnets_cidr_blocks # These are the CIDR blocks of the private subnets so EC2 instances in private subnets can communicate with MongoDB.
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-sg"
  }
}

####################################################
# Security Group for ALB
####################################################
resource "aws_security_group" "alb_security_group" {
  name              = "${var.project_name}-${var.environment}-alb-sg"
  description       = "Security group for Application Load Balancer."
  vpc_id            = var.vpc_id

  egress {
    description      = "Allow all outbound traffic to respond to users and external services."
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # Allow all protocols
    cidr_blocks      = [var.all_traffic] # Allow all outbound IPv4 traffic
    ipv6_cidr_blocks = ["::/0"] # Allow all outbound IPv6 traffic
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-alb-sg"
  }
}

######################################################
# Fetching AWS CloudFront Origin-Facing Prefix List
######################################################
data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

######################################################################################
# Security Group Rule for ALB to allow HTTPS traffic from CloudFront
# ---------------------------------------------------------------------
# I only allow incoming traffic on HTTP and HTTPS from known CloudFront CIDR blocks
# This is an additional layer of security to the Custom Origin Header in CloudFront
######################################################################################
resource "aws_security_group_rule" "alb_cloudfront_https_ingress_only" {
  description       = "Allow HTTPS access only from CloudFront CIDR blocks."
  security_group_id = aws_security_group.alb_security_group.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  type              = "ingress"
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront.id]
}