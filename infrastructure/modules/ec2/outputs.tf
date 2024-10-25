output "ami_id" {
  description = "ID of the Amazon Linux 2 AMI."
  value       = data.aws_ami.amazon_linux_2.id
}

output "ec2_launch_template" {
  description = "ECS EC2 Instances Launch Template."
  value       = aws_launch_template.ec2_launch_template
}

output "ec2_launch_template_id" {
  description = "ID of the ECS EC2 Instances Launch Template."
  value       = aws_launch_template.ec2_launch_template.id
}