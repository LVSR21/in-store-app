#----------------------------------------
# PROVIDER
#----------------------------------------
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      App         = var.project_name
      Environment = var.environment
      Terraform   = "True"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}


#----------------------------------------
# TERRAFORM CONFIGURATION 
#----------------------------------------
terraform {
  # Backend configuration using S3 bucket and DynamoDB Table for remote state storage.

  # Backend must remain commented until the S3 bucket and the DynamoDB table are created.
  # After the creation we can uncomment it, run "terraform init" and then "terraform apply"

  # backend "s3" {
  #   bucket         = "luis-cloud-app-terraform-state-backend"
  #   key            = "modules/infrastructure/remote-backend/terraform.tfstate"
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
      source = "cloudflare/cloudflare"
       version = "~> 4.0" # To use the latest stable version
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}



#----------------------------------------
# REUSABLE MODULES
#----------------------------------------