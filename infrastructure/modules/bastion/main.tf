####################################################
# Get latest Amazon Linux 2 AMI
####################################################
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

####################################################
# Linux EC2 instance for Bastion Host
####################################################
resource "aws_instance" "bastion_ec2" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = var.instance_type
  key_name               = var.instance_key_pair
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.bastion_security_group.id]

  tags = {
    Name = "${var.project_name}-bastion-ec2"
  }
}