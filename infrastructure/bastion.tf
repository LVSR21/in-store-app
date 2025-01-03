##########################
## Create Bastion Hosts ##
##########################

resource "aws_instance" "bastion_host" {
  count                       = 2                                                           # Create 2 Bastion Hosts
  ami                         = data.aws_ami.amazon_linux_2.id                              # Use the Amazon Linux 2 AMI
  instance_type               = "t3.micro"                                                  # Use a t3.micro instance type
  subnet_id                   = aws_subnet.public[count.index].id                           # Use the public subnet
  associate_public_ip_address = true                                                        # Assign a public IP address
  key_name                    = var.instance_key_pair                                       # Use the key pair specified in the variables file
  vpc_security_group_ids      = [aws_security_group.bastion_host.id]                        # Use the security group created for the Bastion Hosts

  tags = {
    Name        = "${var.namespace}_EC2_BastionHost_${var.environment}_${count.index + 1}"  # So each instance has a unique name
    Scenario    = var.scenario
    Environment = var.environment
    Role        = "bastion"                                                                 # This allows the Bastion Host to be identified by my dynamic inventory plugin. This allows me to filter for the Bastion Host specifically in my dynamic inventory.
  }
}


##########################################
## Create Elastic IPs for Bastion Hosts ##
##########################################

resource "aws_eip" "bastion" {
  count    = 2                                                                              # Create 2 Elastic IPs
  instance = aws_instance.bastion_host[count.index].id                                      # Associate the Elastic IP with the Bastion Host
  vpc      = true                                                                           # This Elastic IP is in a VPC

  tags = {
    Name        = "${var.namespace}_EIP_BastionHost_${var.environment}_${count.index + 1}"  # So each Elastic IP has a unique name
    Scenario    = var.scenario
    Environment = var.environment
    Role        = "bastion"
  }
}


#################################################################
# Output the list of Elastic IPs assigned to each Bastion Host ##
#################################################################

output "bastion_eips" {
  description = "Elastic IP of the Bastion hosts" 
  value       = aws_eip.bastion[*].public_ip      # Output the list of Elastic IPs assigned to each Bastion Host
}



# ------------------------- EXPLANATION ------------------------- #
# Bastion Hosts (also called Jump Host) are used to provide secure access to the ECS instances in the private subnets.
# Bastion Hosts are a separate small ECS instance running in the public subnets and only allow access via SSH on port 22.
# Only users with the private key can access the Bastion Hosts.