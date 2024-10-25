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
    cidr_blocks = ["20.223.228.255/32"] # My OpenVPN Server Public IP
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
    delete = "2m"
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

  egress {
    description     = "Allow outbound traffic to MongoDB."
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound HTTPS traffic to VPC endpoints."
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_groups = [aws_security_group.vpc_endpoints_security_group.id]
  }

  lifecycle {
    create_before_destroy = true
  }

  timeouts {
    delete = "2m"
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
    delete = "2m"
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

####################################################
# Security Group for VPC Endpoints
####################################################
resource "aws_security_group" "vpc_endpoints_security_group" {
  description       = "Allow traffic for VPC Endpoints."
  vpc_id            = var.vpc_id

  ingress {
    description     = "Allow inbound traffic from EC2 Instances."
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_security_group.id]
  }

  egress {
    description = "Allow traffic to EC2 Instances." # Grant permission to EC2 instances to reach the VPC Endpoints
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_groups = [aws_security_group.ec2_security_group.id]
  }

  egress {
    description     = "Allow traffic to S3 Gateway Endpoint."
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [var.vpc_endpoint_s3.prefix_list_id]
  }

  egress {
    description     = "Allow traffic to DynamoDB Endpoint."
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [var.vpc_endpoint_dynamodb.prefix_list_id]
  }

  egress {
    description     = "Allow traffic to Interface Endpoints (ECS, ECR, CloudWatch)."
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    self            = true # Allow traffic to other resources using this same security group (in this case VPC Endpoints SG)
  }

  lifecycle {
    create_before_destroy = true
  }

  timeouts {
    delete = "2m"
  }

  tags = {
    Name = "${var.project_name}-vpc-endpoints-sg"
  }
}