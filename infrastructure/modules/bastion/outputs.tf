####################################################
# Output for Bastion EC2 ID
####################################################
output "bastion_ec2_id" {
  description = "ID of the Bastion EC2 instance."
  value       = aws_instance.bastion_ec2.id
}

####################################################
# Output for Bastion EC2 Public IP
####################################################
output "bastion_ec2_public_ip" {
  description = "Public IP of the Bastion EC2 instance."
  value       = aws_instance.bastion_ec2.public_ip
}

####################################################
# Output for Bastion EC2 Security Group ID
####################################################
output "bastion_ec2_security_group_id" {
  description = "ID of the Bastion EC2 Security Group."
  value       = aws_security_group.bastion_security_group.id
}