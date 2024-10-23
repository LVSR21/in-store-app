####################################################
# Project maming variable
####################################################
variable "project_name" {
  description = "Project name."
  type        = string
  default     = "in-store-app"
}




# --------------------------------------------------
# MODULES OUTPUTS VARIABLES
# --------------------------------------------------

# --------------------------------------------------
# ALB Module outputs
# --------------------------------------------------
variable "alb_dns_name" {
  description = "ALB DNS name."
  type = string
}

variable "alb_zone_id" {
  description = "ALB Zone ID."
  type = string
}