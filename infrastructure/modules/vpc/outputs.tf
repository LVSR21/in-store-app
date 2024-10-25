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

output "vpc_endpoint_s3" {
  description = "VPC Endpoint for S3."
  value       = aws_vpc_endpoint.vpc_endpoint_s3
}

output "vpc_endpoint_dynamodb" {
  description = "VPC Endpoint for DynamoDB."
  value       = aws_vpc_endpoint.vpc_endpoint_dynamodb
}