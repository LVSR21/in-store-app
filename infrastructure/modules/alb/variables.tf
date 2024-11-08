variable "project_name" {
    type        = string
}

variable "environment" {
    type        = string
}

variable "domain_name" {
  type        = string
}

variable "cloudfront_origin_secret" {
  type        = string
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
variable "vpc_id" {
  description = "VPC id."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs."
  type        = list(string)
}

# --------------------------------------------------
# Route 53 Module outputs
# --------------------------------------------------
variable "certificate_validation_records" {
  description = "The certificate validation records."
  type        = list(object({
    name    = string
    type    = string
    value   = string
  }))
}

