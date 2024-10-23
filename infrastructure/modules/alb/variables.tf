####################################################
# Project maming variable
####################################################
variable "project_name" {
  description = "Project name."
  type        = string
  default     = "in-store-app"
}

####################################################
# ALB variables
####################################################
variable "load_balancer_internal" {
  description = "Is load balancer internal facing?"
  type        = bool
  default     = false
}

variable "load_balancer_type" {
  description = "Load balancer type."
  type        = string
  default     = "application"
}




# --------------------------------------------------
# MODULES OUTPUTS VARIABLES
# --------------------------------------------------

# --------------------------------------------------
# Security Group Module outputs
# --------------------------------------------------
variable "alb_security_group_id" {
  description = "ID of the ALB Security Group."
  type        = string
}


# --------------------------------------------------
# Netowrk Module outputs
# --------------------------------------------------
variable "public_subnets" {
  description = "List of public subnets."
  type        = set(string)
}


# --------------------------------------------------
# VPC Module outputs
# --------------------------------------------------
variable "vpc_id" {
  description = "VPC id."
  type        = string
}


# --------------------------------------------------
# ALB Module outputs
# --------------------------------------------------
variable "in_store_app_cert_arn" {
  description = "The ARN of the SSL/TLS certificate."
  type        = string
}