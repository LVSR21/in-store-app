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
  description = "ECR repository URL (this corresponds to the ECR repo URI)."
  type        = string
  default     = data.aws_ecr_repository.repo.repository_url
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


# --------------------------------------------------
# ALB Module outputs
# --------------------------------------------------
variable "alb_target_group_arn" {
    description = "ALB Target Group ARN."
    type        = string
}

# --------------------------------------------------
# Secrets Manager Module outputs
# --------------------------------------------------
variable "secrets_policy_arn" {
    description = "The ARN of the IAM policy that allows ECS to read secrets."
    type        = string
}

variable "mongodb_secret_arn" {
    description = "The ARN of the MongoDB secret in AWS Secrets Manager."
    type        = string
}

variable "cloudflare_secret_arn" {
    description = "The ARN of the CloudFlare secret in AWS Secrets Manager."
    type        = string
}