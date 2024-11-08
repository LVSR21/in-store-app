variable "project_name" {
  type        = string
}

variable "environment" {
  type        = string
}


# --------------------------------------------------
# MODULES OUTPUTS VARIABLES
# --------------------------------------------------

# --------------------------------------------------
# Network Module outputs
# --------------------------------------------------
variable "private_subnet_ids" {
  description = "List of IDs of the private subnets."
  type        = list(string)
}

# --------------------------------------------------
# EC2 Module outputs
# --------------------------------------------------
variable "ec2_launch_template_id" {
  description = "ID of the ECS EC2 Instances Launch Template."
  type        = string
  
}