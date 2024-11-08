output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = aws_subnet.private_subnets[*].id
}

output "private_subnets_cidr_blocks" {
  description = "CIDR blocks of the private subnets."
  value       = aws_subnet.private_subnets[*].cidr_block
}