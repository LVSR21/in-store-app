####################################################
# Project maming variable
####################################################
variable "project_name" {
  description = "Project name."
  type        = string
  default     = "in-store-app"
}

####################################################
# Region variable
####################################################
variable "aws_region" {
    description = "AWS region."
    type    = string
    default = "eu-west-2"
}

####################################################
# VPC variables
####################################################
variable "vpc_cidr_block" {
  description = "VPC cidr block."
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
  description = "Enable dns hostnames."
  type        = bool
  default     = true
}




# --------------------------------------------------
# MODULES OUTPUTS VARIABLES
# --------------------------------------------------


# --------------------------------------------------
# Network Module outputs
# --------------------------------------------------
variable "private_subnets" {
  description = "Private Subnets Resource."
  type        = set(string)
}

variable "private_route_table_id" {
  description = "Private Route Table ID."
  type        = string
}


# --------------------------------------------------
# Security Group Module outputs
# -------------------------------------------------
variable "vpc_endpoints_security_group_id" {
  description = "VPC Endpoints Security Group ID."
  type        = string
}
