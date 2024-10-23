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
variable "bastion_ssh_sg" {
  description = "SSH Bastion Host Security Group."
  type        = map(any)
  default = {
    "cidr_block"     = "20.223.228.255/32" # My OpenVPN Server Public IP
    "timeout_delete" = "2m"
  }
}

####################################################
# ECS EC2 Security Group variables
####################################################
variable "mongodb_sg" {
  description = "MongoDB Security Group."
  type        = map(any)
  default = {
    "cidr_block"     = "192.168.248.0/21" # MongoDB VPC CIDR
    "timeout_delete" = "2m"
  }
}

####################################################
# ALB Security Group variables
####################################################
variable "cloudflare_ip_ranges" {
  description = "CloudFlare IP ranges."
  type        = list(string)
  default     = [
    "103.21.244.0/22", # IPv4
    "103.22.200.0/22",
    "103.31.4.0/22",
    "104.16.0.0/13",
    "104.24.0.0/14",
    "108.162.192.0/18",
    "131.0.72.0/22",
    "141.101.64.0/18",
    "162.158.0.0/15",
    "172.64.0.0/13",
    "173.245.48.0/20",
    "188.114.96.0/20",
    "190.93.240.0/20",
    "197.234.240.0/22",
    "198.41.128.0/17",
    "2400:cb00::/32", # IPv6
    "2606:4700::/32",
    "2803:f800::/32",
    "2405:b500::/32",
    "2405:8100::/32",
    "2a06:98c0::/29",
    "2c0f:f248::/32"
  ]
}

variable "all_traffic" {
  description = "Allow all traffic."
  type        = string
  default     = "0.0.0.0/0"
}





# --------------------------------------------------
# MODULES OUTPUTS VARIABLES
# --------------------------------------------------

# --------------------------------------------------
# VPC Module outputs
# --------------------------------------------------
variable "vpc_id" {
  description = "VPC id."
  type        = string
}

# --------------------------------------------------
# Network Module outputs
# --------------------------------------------------
variable "private_subnets_cidr_blocks" {
  description = "CIDR blocks of the private subnets."
  type        = list(string)
}
