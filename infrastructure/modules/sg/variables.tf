variable "project_name" {
    type        = string
}

variable "environment" {
    type        = string
}

variable "all_traffic" {
  type        = string
}

variable "open_vpn_ip" {
  type        = string
}

# --------------------------------------------------
# MODULES OUTPUTS VARIABLES
# --------------------------------------------------

# --------------------------------------------------
# Network Module outputs
# --------------------------------------------------
variable "vpc_id" {
  description = "VPC id."
  type        = string
}

variable "vpc_endpoint_s3_prefix_list_id" {
  description = "Prefix list ID for the S3 VPC Endpoint."
  type        = string
}

# --------------------------------------------------
# Network Module outputs
# --------------------------------------------------
variable "private_subnets_cidr_blocks" {
  description = "CIDR blocks of the private subnets."
  type        = list(string)
}
