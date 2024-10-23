####################################################
# Project maming variable
####################################################
variable "project_name" {
  description = "Project name."
  type        = string
  default     = "in-store-app"
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