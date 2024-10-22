####################################################
# Get list of available AZs
####################################################
data "aws_availability_zones" "available_zones" {
  state = "available"
}

####################################################
# VPC
####################################################
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

####################################################
# INTERNET GATEWAY
####################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

####################################################
# PUBLIC SUBNETS
####################################################
resource "aws_subnet" "public_subnets" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = 2
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name   = "${var.project_name}-public-subnet${count.index + 1}"
    Subnet = "Public"

  }
}

####################################################
# PRIVATE SUBNETS
####################################################
resource "aws_subnet" "private_subnets" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = 2
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, 2 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name   = "${var.project_name}-private-subnet${count.index + 1}"
    Subnet = "Private"
  }
}

####################################################
# PUBLIC ROUTE TABLE
####################################################
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.all_traffic
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-route-table"
  }
}

####################################################
# Set default route table as PRIVATE ROUTE TABLE
####################################################
resource "aws_default_route_table" "private_route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  tags = {
    Name = "${var.project_name}-private-route-table"
  }
}

####################################################
# PUBLIC TABLE ROUTE ASSOCIATION
####################################################
resource "aws_route_table_association" "public_route_table_association" {
  count          = 2
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

####################################################
# PRIVATE TABLE ROUTE ASSOCIATION
####################################################
resource "aws_route_table_association" "private_route_table_association" {
  count          = 2
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_default_route_table.private_route_table.id
}