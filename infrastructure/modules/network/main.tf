####################################################
# Get list of available AZs
####################################################
data "aws_availability_zones" "available_zones" {
  state = "available"
}

####################################################
# Internet Gateway
####################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

####################################################
# Public Subnets
####################################################
resource "aws_subnet" "public_subnets" {
  vpc_id                  = var.vpc_id
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
# Private Subnets
####################################################
resource "aws_subnet" "private_subnets" {
  vpc_id                  = var.vpc.id
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
# Public Route Table
####################################################
resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc.id

  route {
    cidr_block = var.all_traffic
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-route-table"
  }
}

####################################################
# Set default route table as Private Route Table
####################################################
resource "aws_default_route_table" "private_route_table" {
  default_route_table_id = var.aws_vpc.default_route_table_id
  tags = {
    Name = "${var.project_name}-private-route-table"
  }
}

####################################################
# Public Route Table Association
####################################################
resource "aws_route_table_association" "public_route_table_association" {
  count          = 2
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

####################################################
# Private Route Table Association
####################################################
resource "aws_route_table_association" "private_route_table_association" {
  count          = 2
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_default_route_table.private_route_table.id
}