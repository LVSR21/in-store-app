####################################################
# Get list of available AZs
####################################################
data "aws_availability_zones" "available_zones" {
  state = "available"
}

####################################################
# Virtual Private Cloud (VPC)
####################################################
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}

####################################################
# Internet Gateway
####################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

####################################################################
# Public Subnets (one public subnet per AZ)
# ------------------------------------------
# Puclic Subnets will be used for the ALB and the Bastion Host
####################################################################
resource "aws_subnet" "public_subnets" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = 2
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name   = "${var.project_name}-${var.environment}-public-subnet${count.index}"
  }
}

############################################################
# Public Route Table with egress route to the internet
# ------------------------------------------------------
# All public subnets will use the same route table.
############################################################
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.all_traffic
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-route-table"
  }
}

####################################################
# Associate Route Table with Public Subnets
####################################################
resource "aws_route_table_association" "public_route_table_association" {
  count          = 2
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

##############################################################
# Make Public Route Table the main Route Table for the VPC
##############################################################
resource "aws_main_route_table_association" "public_route_table_association_main" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.public_route_table.id
}

############################################################
# Elastic IP per AZ (one for each NAT Gateway in each AZ)
############################################################
resource "aws_eip" "nat_gateway_eip" {
  count = 2
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-gateway-eip"
  }
}

####################################################################################################################
# NAT Gateway (one per AZ)
# -----------------------------------------------
# Added NAT Gateway in public subnets to allow container instances in the private subnets to access the internet.
####################################################################################################################
resource "aws_nat_gateway" "nat_gateway" {
  count           = 2
  subnet_id       = aws_subnet.public_subnets[count.index].id
  allocation_id   = aws_eip.nat_gateway_eip[count.index].id

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-gateway"
  }
}

##############################################################
# Private Subnets (one private subnet per AZ)
# ------------------------------------------
# Private Subnets will be used for the Container Instances
##############################################################
resource "aws_subnet" "private_subnets" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = 2
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name   = "${var.project_name}-${var.environment}-private-subnet${count.index}"
  }
}

###################################################################################################
# Private Route Tables for outbound internet access via NAT Gateway
# -----------------------------------------------------------------------
# Each private subnet will have its own route table to enable outbound traffic to the internet.
###################################################################################################
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  count = 2 # I need one route table per private subnet because I have one NAT Gateway in each AZ (public subnet). This enables outbound traffic from the resources in the private subnet to the internet.

route {
    cidr_block = var.all_traffic
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-private-route-table${count.index}"
  }
}

####################################################
# Associate Route Tables for each Private Subnet
####################################################
resource "aws_route_table_association" "private_route_table_association" {
  count          = 2
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}