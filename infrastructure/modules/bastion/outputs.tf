output "bastion_host_id" {
  description = "ID of the Bastion EC2 instance."
  value       = aws_instance.bastion_host.id
}

output "bastion_host_public_ip" {
  description = "Public IP of the Bastion EC2 instance."
  value       = aws_instance.bastion_host.public_ip
}