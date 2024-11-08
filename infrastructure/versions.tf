#----------------------------------------
# Terraform Version Configuration 
#----------------------------------------
terraform {
    # Backend configuration using S3 bucket and DynamoDB Table for remote state storage.

    # Backend must remain commented until the S3 bucket and the DynamoDB table are created.
    # After the creation we can uncomment it, run "terraform init" and then "terraform apply"

    # backend "s3" {
    #   bucket         = "in-store-app-terraform-state-backend"
    #   key            = "infrastructure/modules/remote_backend/terraform.tfstate"
    #   region         = "eu-west-2"
    #   dynamodb_table = "dynamodb-terraform-state-lock-table"
    #   encrypt        = true
    # }

    # Required providers and their versions
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = ">= 4.0"
        }

        cloudflare = {
        source  = "cloudflare/cloudflare"
        version = "~> 4.0"  # Use the latest stable version
        }

        random = {
        source  = "hashicorp/random" # Useful to create random suffixes to resource names to avoid conflicts when deploying multiple instances of a resource, such as S3 buckets or security groups
        version = ">= 3.0"
        }
    }
}