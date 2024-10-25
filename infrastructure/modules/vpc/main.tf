####################################################
# Virtual Private Cloud (VPC)
####################################################
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

##########################################################################
# Create VPC Endpoints for following Services:
# com.amazonaws.${var.aws_region}.ecs-agent     - VPC Interface Endpoint  
# com.amazonaws.${var.aws_region}.ecs-telemetry - VPC Interface Endpoint
# com.amazonaws.${var.aws_region}.ecs           - VPC Interface Endpoint
# com.amazonaws.${var.aws_region}.ecr.dkr       - VPC Interface Endpoint
# com.amazonaws.${var.aws_region}.ecr.api       - VPC Interface Endpoint
# com.amazonaws.${var.aws_region}.logs          - VPC Interface Endpoint
# com.amazonaws.${var.aws_region}.s3            - VPC Gateway Endpoint
##########################################################################
locals {
  endpoint_list = ["com.amazonaws.${var.aws_region}.ecs-agent",
    "com.amazonaws.${var.aws_region}.ecs-telemetry",
    "com.amazonaws.${var.aws_region}.ecs",
    "com.amazonaws.${var.aws_region}.ecr.dkr",
    "com.amazonaws.${var.aws_region}.ecr.api",
    "com.amazonaws.${var.aws_region}.logs",
  ]
}

####################################################
# VPC Endpoints
####################################################
resource "aws_vpc_endpoint" "vpc_endpoint" {
  vpc_id = aws_vpc.vpc.id
  count = 6
  vpc_endpoint_type = "Interface"
  service_name = local.endpoint_list[count.index]
  subnet_ids = var.private_subnets[*]
  private_dns_enabled = true
  security_group_ids = [var.vpc_endpoints_security_group_id]

  tags = {
    Name = "${var.project_name}-vpc-endpoint-${local.endpoint_list[count.index]}"
  }
}

####################################################
# VPC Gateway Endpoint for S3
####################################################
resource "aws_vpc_endpoint" "vpc_endpoint_s3" {
  vpc_id = aws_vpc.vpc.id
  vpc_endpoint_type = "Gateway"
  service_name = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = [var.private_route_table_id]

  tags = {
    Name = "${var.project_name}-vpc-endpoint-com.amazonaws.${var.aws_region}.s3"
  }
}

####################################################
# Create VPC Gateway Endpoint for DynamoDB
####################################################
resource "aws_vpc_endpoint" "vpc_endpoint_dynamodb" {
  vpc_id = aws_vpc.vpc.id
  vpc_endpoint_type = "Gateway"
  service_name = "com.amazonaws.${var.aws_region}.dynamodb"
  route_table_ids = [var.private_route_table_id]

  tags = {
    Name = "${var.project_name}-vpc-endpoint-com.amazonaws.${var.aws_region}.dynamodb"
  }
}






####################################################
# VPC PEEERING CONNECTION TO MONGODB VPC
####################################################