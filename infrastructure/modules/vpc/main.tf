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
# com.amazonaws.${var.aws_region}.ecs-agent               - VPC Interface Endpoint  
# com.amazonaws.${var.aws_region}.ecs-telemetry           - VPC Interface Endpoint
# com.amazonaws.${var.aws_region}.ecs                     - VPC Interface Endpoint
# com.amazonaws.${var.aws_region}.ecr.dkr                 - VPC Interface Endpoint
# com.amazonaws.${var.aws_region}.ecr.api                 - VPC Interface Endpoint
# com.amazonaws.${var.aws_region}.logs                    - VPC Interface Endpoint
# com.amazonaws.${var.aws_region}.secretsmanager          - VPC Interface Endpoint
# com.amazonaws.${var.aws_region}.s3                      - VPC Gateway Endpoint
# com.amazonaws.${var.aws_region}.dynamodb                - VPC Gateway Endpoint
##########################################################################
locals {
  interface_endpoint_list = [
    "com.amazonaws.${var.aws_region}.ecs-agent",
    "com.amazonaws.${var.aws_region}.ecs-telemetry",
    "com.amazonaws.${var.aws_region}.ecs",
    "com.amazonaws.${var.aws_region}.ecr.dkr",
    "com.amazonaws.${var.aws_region}.ecr.api",
    "com.amazonaws.${var.aws_region}.logs",
    "com.amazonaws.${var.aws_region}.secretsmanager"
  ]

  gateway_endpoint_list = [
    "com.amazonaws.${var.aws_region}.s3",
    "com.amazonaws.${var.aws_region}.dynamodb"
  ]
}

####################################################
# VPC Interface Endpoints
####################################################
resource "aws_vpc_endpoint" "vpc_interface_endpoint" {
  vpc_id = aws_vpc.vpc.id
  count = length(local.interface_endpoint_list)
  vpc_endpoint_type = "Interface"
  service_name = local.interface_endpoint_list[count.index]
  subnet_ids = var.private_subnets[*]
  private_dns_enabled = true
  security_group_ids = [var.vpc_endpoints_security_group_id]

  tags = {
    Name = "${var.project_name}-vpc-interface-endpoint-${local.interface_endpoint_list[count.index]}"
  }
}

####################################################
# VPC Gateway Endpoints
####################################################
resource "aws_vpc_endpoint" "vpc_gateway_endpoint" {
  vpc_id = aws_vpc.vpc.id
  count = length(local.gateway_endpoint_list)
  vpc_endpoint_type = "Gateway"
  service_name = loal.gateway_endpoint_list[count.index]
  route_table_ids = [var.private_route_table_id]

  tags = {
    Name = "${var.project_name}-vpc-gateway-endpoint-${local.gateway_endpoint_list[count.index]}"
  }
}
