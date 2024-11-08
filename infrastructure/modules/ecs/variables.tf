variable "project_name" {
    type        = string
}

variable "environment" {
    type        = string
}

variable "aws_region" {
    type    = string
}

# --------------------------------------------------
# MODULES OUTPUTS VARIABLES
# --------------------------------------------------

# --------------------------------------------------
# CloudWatch Module outputs
# --------------------------------------------------
variable "cloudwatch_log_group_name" {
    description = "CloudWatch Log Group Name."
    type        = string
}

# --------------------------------------------------
# ECR Module outputs
# --------------------------------------------------
variable "ecr_repository_url" {
    description = "ECR Repository URL."
    type        = string
}

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
variable "mongodb_secret_arn" {
    description = "The ARN of the MongoDB secret in AWS Secrets Manager."
    type        = string
}

variable "mongodb_secrets_policy_arn" {
    description = "The ARN of the IAM policy that allows ECS to read secrets."
    type        = string
}