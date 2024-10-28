##########################################################
# Project naming variable
##########################################################
variable "project_name" {
  description = "Project name."
  type        = string
  default     = "luis-cloud-app"
}

##########################################################
# S3 Bucjet variable
##########################################################
variable "s3_bucket_name" {
  description = "The name of the S3 bucket (must be globally unique)."
  type        = string
  default     = "in-store-app-terraform-state-backend"
}

##########################################################
# DynamoDB Table variable
##########################################################
variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table (must be unique in this AWS account)."
  type        = string
  default     = "dynamodb-terraform-state-lock-table"
}