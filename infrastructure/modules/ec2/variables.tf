####################################################
# Project maming variable
####################################################
variable "project_name" {
  description = "Project name."
  type        = string
  default     = "in-store-app"
}

####################################################
# ECS EC2 variables
####################################################
variable "ec2_instance_type" {
  description = "EC2 instance type for ECS cluster."
  type        = string
  default     = "t2.micro"
}

variable "instance_key_pair" {
  description = "EC2 instance key pair name."
  type        = string
  default     = "in-store-app-key-pair" # Please note that this key pair already exists in my AWS account under 'key pair' section in the eu-west-2 region (London).
}





# --------------------------------------------------
# MODULES OUTPUTS VARIABLES
# --------------------------------------------------

# --------------------------------------------------
# Security Group Module outputs
# --------------------------------------------------
variable "bastion_security_group_id" {
  description = "ID of the Bastion Host Security Group."
  type        = string
}

variable "ec2_security_group_id" {
  description = "ID of the ECS EC2 Instances Security Group."
  type        = string
}

variable "alb_security_group_id" {
  description = "ID of the ALB Security Group."
  type        = string
}

