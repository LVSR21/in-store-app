####################################################
# Project maming variable
####################################################
variable "project_name" {
  description = "Project name."
  type        = string
  default     = "in-store-app"
}

####################################################
# Bastion Host EC2 variables
####################################################
variable "instance_type" {
  description = "EC2 instance type to launch."
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
# Network Module outputs
# --------------------------------------------------
variable "id_of_first_public_subnet" {
  description = "CIDR blocks of the private subnets."
  type        = string
}

# --------------------------------------------------
# Security Group Module outputs
# --------------------------------------------------
variable "bastion_security_group_id" {
  description = "ID of the Bastion Security Group."
  type        = string
}

