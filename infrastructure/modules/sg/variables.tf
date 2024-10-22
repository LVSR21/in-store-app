####################################################
# Project maming variable
####################################################
variable "project_name" {
  description = "Project name."
  type        = string
  default     = "in-store-app"
}

####################################################
# Bastion Host Security Group variables
####################################################
variable "ssh_sg" {
  description = "SSH Bastion Host Security Group."
  type = map(any)
  default = {
    "cidr_block" = "20.223.228.255" # VPN IP
    "timeout_delete" = "2m"
  }
}


# --------------------------------------------------
# MODULES OUTPUTS VARIABLES
# --------------------------------------------------

# --------------------------------------------------
# Network Module outputs
# --------------------------------------------------
variable "vpc_id" {
  description = "VPC id from network module outputs."
  type        = string
}

variable "private_subnets_cidr_blocks" {
  description = "CIDR blocks of the private subnets from network module outputs."
  type        = list(string)
}