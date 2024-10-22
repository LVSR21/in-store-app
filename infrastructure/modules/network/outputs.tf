####################################################
# VPC output
####################################################
output "vpc_id" {
  description = "VPC id."
  value       = aws_vpc.vpc.id
  
}

####################################################
# PUBLIC SUBNETS output
####################################################
output "public_subnets" {
  description = "Public Subnets Resource."
  value       = aws_subnet.public_subnets
}

####################################################
# PRIVATE SUBNETS output
####################################################
output "private_subnets" {
  description = "Private Subnets Resource."
  value       = aws_subnet.private_subnets
}

####################################################
# PRIVATE SUBNETS CIDR BLOCKS output
####################################################
output "private_subnets_cidr_blocks" {
  description = "CIDR blocks of the private subnets."
  value       = aws_subnet.private_subnets[*].cidr_block
}

####################################################
# PUBLIC ROUTE TABLE output
####################################################
output "public_route_table" {
  description = "Public Route Table Resource."
  value       = aws_route_table.public_route_table
}

####################################################
# PRIVATE ROUTE TABLE output
####################################################
output "private_route_table" {
  description = "Private Route Table Resource."
  value       = aws_default_route_table.private_route_table
}

