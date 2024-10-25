output "bastion_security_group_id" {
  description = "ID of the Bastion Host Security Group."
  value       = aws_security_group.bastion_security_group.id
}

output "ec2_security_group_id" {
  description = "ID of the ECS EC2 Instances Security Group."
  value       = aws_security_group.ec2_security_group.id
}

output "alb_security_group_id" {
  description = "ID of the ALB Security Group."
  value       = aws_security_group.alb_security_group.id
}

output "vpc_endpoints_security_group_id" {
  description = "ID of the Security Group for VPC Endpoints."
  value = aws_security_group.vpc_endpoints_security_group.id
}
