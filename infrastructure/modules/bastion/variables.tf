variable "project_name" {
    type        = string
}

variable "environment" {
    type        = string
}

variable "ec2_instance_type" {
  type        = string
}

variable "instance_key_pair" {
  type        = string
}




# --------------------------------------------------
# MODULES OUTPUTS VARIABLES
# --------------------------------------------------

# --------------------------------------------------
# Network Module outputs
# --------------------------------------------------
variable "public_subnet_ids" {
  description = "IDs of the public subnets."
  type        = list(string)
}

# --------------------------------------------------
# Security Group Module outputs
# --------------------------------------------------
variable "bastion_security_group_id" {
  description = "ID of the Bastion Security Group."
  type        = string
}

