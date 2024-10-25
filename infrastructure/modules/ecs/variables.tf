####################################################
# Project maming variable
####################################################
variable "project_name" {
  description = "Project name."
  type        = string
  default     = "in-store-app"
}

####################################################
# ECS Cluster variables
####################################################
variable "ecs_cluster_name" {
  description = "ECS cluster name."
  type        = string
  default     = "in-store-app-ecs-cluster"
}

####################################################
# ECR variables
####################################################
variable "ecr_repository_url" {
  description = "ECR repository URL."
  type        = string
  default     = "123456789012.dkr.ecr.eu-west-2.amazonaws.com" # Change this to my ECR repository URL
  
}


####################################################
# Region variables
####################################################
variable "aws_region" {
    description = "AWS region."
    type    = string
    default = "eu-west-2"
}




# --------------------------------------------------
# MODULES OUTPUTS VARIABLES
# --------------------------------------------------

# --------------------------------------------------
# Auto Scaling Group Module outputs
# --------------------------------------------------
variable "auto_scaling_group_arn" {
    description = "Auto Scaling Group ARN."
    type        = string
}