output "public_subnets" {
  description = "Public Subnets Resource."
  value       = aws_subnet.public_subnets
}

output "id_of_first_public_subnet" {
  description = "ID of the first public subnet."
  value       = aws_subnet.public_subnets[0].id
}

output "private_subnets" {
  description = "Private Subnets Resource."
  value       = aws_subnet.private_subnets
}

output "private_subnets_cidr_blocks" {
  description = "CIDR blocks of the private subnets."
  value       = aws_subnet.private_subnets[*].cidr_block
}

output "public_route_table" {
  description = "Public Route Table Resource."
  value       = aws_route_table.public_route_table
}

output "private_route_table" {
  description = "Private Route Table Resource."
  value       = aws_default_route_table.private_route_table
}

