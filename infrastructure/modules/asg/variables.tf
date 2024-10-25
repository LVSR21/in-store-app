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
# Network Module outputs
# --------------------------------------------------
variable "private_subnets" {
  description = "Private Subnets Resource."
  type        = set(string)
}


# --------------------------------------------------
# EC2 Module outputs
# --------------------------------------------------
variable "ec2_launch_template" {
  description = "ECS EC2 Instances Launch Template."
  type        = object
}

variable "ec2_launch_template_id" {
  description = "ID of the ECS EC2 Instances Launch Template."
  type        = string
  
}