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
# Security Group Module outputs
# --------------------------------------------------
variable "ec2_security_group_id" {
  description = "ID of the EC2 Instances Security Group."
  type        = string
}

# --------------------------------------------------
# Secrets Manager Module outputs
# --------------------------------------------------
variable "cloudfront_secrets_policy_arn" {
  description = "The ARN of the CloudFront secret in AWS Secrets Manager."
  type        = string
}