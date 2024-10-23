####################################################
# Security Group for Bastion Host EC2 Instance
####################################################
resource "aws_security_group" "bastion_security_group" {
  description   = "Allow traffic for EC2 Bastion Host."
  vpc_id        = var.vpc_id

  ingress {
    description = "Allows SSH access from VPN IP."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_ssh_sg["cidr_block"]]
  }

  egress {
    description = "Restrict outboudb traffic to EC2 instances in private subnets."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.private_subnets_cidr_blocks
  }

  lifecycle {
    create_before_destroy = true
  }

  timeouts {
    delete = var.bastion_ssh_sg["timeout_delete"]
  }

  tags = {
    Name = "${var.project_name}-bastion-sg"
  }
}

####################################################
# Security Group for ECS EC2 Instances
####################################################
resource "aws_security_group" "ec2_security_group" {
  description       = "Allow traffic for ECS EC2."
  vpc_id            = var.vpc_id

  ingress {
    description     = "Allow inbound traffic from ALB on HTTP port."
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

  ingress {
    description      = "Allow inbound traffic from ECS EC2 instances to MongoDB."
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    cidr_blocks     = [var.mongodb_sg["cidr_block"]]
  }

  egress {
    description     = "Allow outbound traffic to MongoDB."
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    cidr_blocks     = [var.mongodb_sg["cidr_block"]]
  }

  lifecycle {
    create_before_destroy = true
  }

  timeouts {
    delete = var.bastion_ssh_sg["timeout_delete"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

####################################################
# Security Group for ALB
####################################################
resource "aws_security_group" "alb_security_group" {
  description       = "Allow traffic for Application Load Balancer."
  vpc_id            = var.vpc_id

  ingress {
    description     = "Allow inbound traffic from CloudFlare on HTTP port."
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = var.cloudflare_ip_ranges
  }

  ingress {
    description     = "Allow inbound traffic from anywhere on the internet on HTTPS port."
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = var.cloudflare_ip_ranges
  }

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

  timeouts {
    delete = var.alb_sg["timeout_delete"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}