output "bastion_ec2_id" {
  description = "ID of the Bastion EC2 instance."
  value       = aws_instance.bastion_ec2.id
}

output "bastion_ec2_public_ip" {
  description = "Public IP of the Bastion EC2 instance."
  value       = aws_instance.bastion_ec2.public_ip
}