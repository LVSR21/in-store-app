output "ami_id" {
  description = "ID of the Amazon Linux 2 AMI."
  value       = data.aws_ami.amazon-linux-2.id
}
