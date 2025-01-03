################
## Create VPC ##
################

resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr_block # VPC CIDR block
  enable_dns_support   = true               # Enable DNS support
  enable_dns_hostnames = true               # Enable DNS hostnames

  tags = {
    Name     = "${var.namespace}_VPC_${var.environment}"
    Scenario = var.scenario
  }
}


###############################################################################################
## Create Internet Gateway for egress/ingress connections to resources in the public subnets ##
###############################################################################################

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id # The ID of the VPC where the Internet Gateway will be created

  tags = {
    Name     = "${var.namespace}_InternetGateway_${var.environment}"
    Scenario = var.scenario
  }
}


##########################################################################
## Get a list of all AZs available in the region configured (eu-west-2) ##
##########################################################################

data "aws_availability_zones" "available" {
  state = "available" # The state of the availability zones - 'available' means that the AZs are available for use
}


######################################################
## Create Public Subnets (one public subnet per AZ) ##
######################################################

resource "aws_subnet" "public" {
  count                   = var.az_count                                                  # The number of public subnets to create
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, var.az_count + count.index) # The CIDR block of the subnet - in here I am using the cidrsubnet function to create a subnet with a /24 CIDR block. One public subnet 10.0.0.0/24 and the other 10.0.1.0/24. Please note that /24 has 254 usable IP addresses that can be assigned to EC2 instances, Load Balancers and other AWS services.
  availability_zone       = data.aws_availability_zones.available.names[count.index]      # The availability zone of the subnet - in here I am using the data source to fetch the available AZs in the region and then using the 'count.index' to loop through the available AZs. One AZ is eu-west-2a and the other is eu-west-2b.
  vpc_id                  = aws_vpc.default.id                                            # The VPC ID where the subnet will be created
  map_public_ip_on_launch = true                                                          # This enables the automatic assignment of public IP addresses to instances launched in the subnet

  tags = {
    Name     = "${var.namespace}_PublicSubnet_${count.index}_${var.environment}"
    Scenario = var.scenario
  }
}


#################################################
## Create a Route Table for the Public Subnets ##
#################################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id                     # The VPC ID where the Route Table will be created

  route {                                         # Route configurations:
    cidr_block = "0.0.0.0/0"                      # The CIDR block of the route - in this case allowing all traffic to the internet
    gateway_id = aws_internet_gateway.default.id  # The ID of the Internet Gateway to route the traffic to the internet 
  }

  tags = {
    Name     = "${var.namespace}_PublicRouteTable_${var.environment}"
    Scenario = var.scenario
  }
}


#############################################################
## Create a Route Table Association for the Public Subnets ##
#############################################################

resource "aws_route_table_association" "public" {
  count          = var.az_count                       # The number of public subnets
  subnet_id      = aws_subnet.public[count.index].id  # The ID of the public subnet
  route_table_id = aws_route_table.public.id          # The ID of the Route Table
}


##########################################################
## Make my Route Table the main Route Table for the VPC ##
##########################################################

resource "aws_main_route_table_association" "public_main" {
  vpc_id         = aws_vpc.default.id         # The VPC ID where the main Route Table will be associated
  route_table_id = aws_route_table.public.id  # The ID of the Route Table
}


#########################################################################
## Creates one Elastic IP per AZ (one for each NAT Gateway in each AZ) ##
#########################################################################

resource "aws_eip" "nat_gateway" {
  count = var.az_count  # The number of Elastic IPs to create
  vpc   = true          # This Elastic IP is in a VPC

  tags = {
    Name     = "${var.namespace}_EIP_${count.index}_${var.environment}"
    Scenario = var.scenario
    Environment = var.environment
  }
}


####################################
## Creates one NAT Gateway per AZ ##
####################################

resource "aws_nat_gateway" "nat_gateway" {
  count         = var.az_count                        # The number of NAT Gateways to create
  subnet_id     = aws_subnet.public[count.index].id   # The ID of the public subnet where the NAT Gateway will be created
  allocation_id = aws_eip.nat_gateway[count.index].id # The ID of the Elastic IP to associate with the NAT Gateway

  tags = {
    Name     = "${var.namespace}_NATGateway_${count.index}_${var.environment}"
    Scenario = var.scenario
    Environment = var.environment
  }
}


########################################################
## Create Private Subnets (one private subnet per AZ) ##
########################################################

resource "aws_subnet" "private" {
  count             = var.az_count                                              # The number of private subnets to create
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index)            # The CIDR block of the subnet - in here I am using the cidrsubnet function to create a subnet with a /24 CIDR block. One private subnet 10.0.2.0/24 and the other 10.0.3.0/24.
  availability_zone = data.aws_availability_zones.available.names[count.index]  # The availability zone of the subnet - in here I am using the data source to fetch the available AZs in the region and then using the 'count.index' to loop through the available AZs (eu-west-2a and eu-west-2b).
  vpc_id            = aws_vpc.default.id                                        # The VPC ID where the subnet will be created

  tags = {
    Name     = "${var.namespace}_PrivateSubnet_${count.index}_${var.environment}"
    Scenario = var.scenario
  }
}


########################################################################
## Create a Route Table for the Private Subnets using the NAT Gateway ##
########################################################################

resource "aws_route_table" "private" {
  count  = var.az_count                                           # The number of private subnets
  vpc_id = aws_vpc.default.id                                     # The VPC ID where the Route Table will be created

  route {                                                         # Route configurations:
    cidr_block     = "0.0.0.0/0"                                  # The CIDR block of the route - in this case allowing all traffic to the internet
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id  # The ID of the NAT Gateway to route the traffic to the internet
  }

  tags = {
    Name     = "${var.namespace}_PrivateRouteTable_${count.index}_${var.environment}"
    Scenario = var.scenario
  }
}


##############################################################
## Create a Route Table Association for the Private Subnets ##
##############################################################

resource "aws_route_table_association" "private" {
  count          = var.az_count                             # The number of private subnets
  subnet_id      = aws_subnet.private[count.index].id       # The ID of the private subnet
  route_table_id = aws_route_table.private[count.index].id  # The ID of the Route Table
}


##############################################################
## Output NAT Gateway EIPs to add them to the MongoDB Atlas ##
##############################################################

output "nat_gateway_eips" {
  description = "Elastic IP addresses of NAT Gateways"
  value       = aws_eip.nat_gateway[*].public_ip
}



#------------------------- EXPLANATION -------------------------#
# AWS Region is a physical geographical location where AWS has multiple data centers. Each region is a separate geographic are, completely independent from other Regions and contains multiple Availability Zones (AZs). Regions are used for compliance, to meet data sovereignty requirements, latency optimisation (deploy apps closer to end users), disaster recovery and more. In my case, I am using the eu-west-2 region which is located in London, UK.
# VPC (Virtual Private Cloud) is a virtual network that is isolated from other virtual networks in the AWS cloud. It's like my own isolated data center in the cloud. It allows me to launch AWS resources in a virtual network that I define. It provides control over the virtual network environment, including selecting my own IP address range, creating subnets, and configuring route tables and network gateways. In my case my VPC has a CIDR block of 10.0.0.0/16 which allows me to have 65,536 IP addresses.
# Internet Gateway (IGW) is a horizontally scaled, redundant, and highly available AWS service that acts as a gateway between my VPC and the public internet. It's like a door that allows communication between my VPC and the internet.
# AZs (Availability Zones) are physically separate data centers withing an AWS region. They provide high availability, protects against data center failure (disaster recovery), latency optimisation (resources can be placed closer to end users), and more.
# Public Subnets are a logical subdivision of an IP network. Public subnets have a route table entry pointing to an Internet Gateway and they can communicate directly with the internet.
# Private Subnets are a logical subdivision of an IP network. Private subnets don't have a direct access to the internet, instead, they have a route table entry pointing to a NAT Gateway that allows them to communicate with the internet. They are used for protected resources.
# Route Table acts as a traffic controller/router for my VPC. Contains rules (routes) that determine where network traffic is directed. Each route specifies a destination CIDR block and a target (e.g. an internet gateway) to send the traffic to.
# Route Table Association links a subnet to a specific route table. Determines how traffic from the subnet is routed. Each subnet must be associated with exactly one route table.