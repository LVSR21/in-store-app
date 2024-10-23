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
# VPC PEEERING CONNECTION TO MONGODB VPC
####################################################