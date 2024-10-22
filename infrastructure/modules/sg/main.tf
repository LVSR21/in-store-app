####################################################
# Security Group for Bastion Host
####################################################
resource "aws_security_group" "bastion_security_group" {
  description = "Allow traffic for EC2 Bastion Host"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allows SSH access from VPN IP."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_sg["cidr_block"]]
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
    delete = var.ssh_sg["timeout_delete"]
  }

  tags = {
    Name = "${var.project_name}-bastion-sg"
  }
}