########################################################################################################################
## Bastion host SG and EC2 Instance
########################################################################################################################

resource "aws_security_group" "bastion_host" {
  name        = "${var.namespace}_SecurityGroup_BastionHost_${var.environment}"
  description = "Bastion host Security Group"
  vpc_id      = aws_vpc.default.id

  ingress {
    description = "Allow SSH from trusted IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["20.223.228.255/32"] # This is the Server Public IP of my OpenVPN
  }

  egress {
    description     = "Allow SSH to EC2 instances"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = [var.vpc_cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Scenario = var.scenario
  }
}

resource "aws_instance" "bastion_host" {
  count                       = 2
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public[count.index].id
  associate_public_ip_address = true
  key_name                    = var.instance_key_pair
  vpc_security_group_ids      = [aws_security_group.bastion_host.id]

  tags = {
    Name        = "${var.namespace}_EC2_BastionHost_${var.environment}_${count.index + 1}" # So each instance has a unique name.
    Scenario    = var.scenario
    Environment = var.environment
    Role        = "bastion" # This allows the Bastion Host to be identifies by my dynamic inventory plugin. This allows me to filter for the Bastion Host specifically in my dynamic inventory.
  }
}

resource "aws_eip" "bastion" {
  count    = 2
  instance = aws_instance.bastion_host[count.index].id
  vpc      = true

  tags = {
    Name        = "${var.namespace}_EIP_BastionHost_${var.environment}_${count.index + 1}"
    Scenario    = var.scenario
    Environment = var.environment
    Role        = "bastion"
  }
}


output "bastion_eips" {
  description = "Elastic IP of the Bastion hosts"
  value       = aws_eip.bastion[*].public_ip # Output the list of Elastic IPs assigned to each Bastion Host
}