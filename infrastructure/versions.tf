terraform {
  # Backend configuration using S3 bucket and DynamoDB Table for remote state storage.

  # Backend must remain commented until the S3 bucket and the DynamoDB table are created.
  # After the creation we can uncomment it, run "terraform init" and then "terraform apply"

  backend "s3" {
    bucket         = "in-store-app-terraform-state-backend"
    key            = "infrastructure/modules/remote_backend/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "jd-dynamodb-terraform-state-lock-table"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.3.0"
}