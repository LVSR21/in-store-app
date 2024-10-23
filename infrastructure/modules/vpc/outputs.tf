output "aws_vpc" {
  description = "VPC Resource."
  value       = aws_vpc.vpc
}

output "vpc_id" {
  description = "VPC id."
  value       = aws_vpc.vpc.id
  
}

output "vpc_cidr_block" {
  description = "VPC cidr block."
  value       = var.vpc.cidr_block
}