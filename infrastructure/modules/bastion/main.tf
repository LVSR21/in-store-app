####################################################
# Get latest Amazon Linux 2 AMI
####################################################
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"] # This specifies that I want AMIs owned by Amazon.

  filter {
    name   = "virtualization-type"
    values = ["hvm"] # This specifies that only AMIs with HVM virtualization will be selected.
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"] # This restricts the search to AMIs owned by Amazon.
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"] # This filters by AMI names that match the specified pattern.
  }
}

####################################################
# Linux EC2 instance for Bastion Host
####################################################
resource "aws_instance" "bastion_host" {
  count                       = 2
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.ec2_instance_type
  key_name                    = var.instance_key_pair
  subnet_id                   = var.public_subnet_ids[count.index] # Assign each instance to a different public subnet
  vpc_security_group_ids      = [var.bastion_security_group_id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-${var.environment}-bastion-host-${count.index + 1}" # So each instance has a unique name.
  }
}
