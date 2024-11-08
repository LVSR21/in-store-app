output "ec2_launch_template_id" {
  description = "ID of the ECS EC2 Instances Launch Template."
  value       = aws_launch_template.ec2_launch_template.id
}