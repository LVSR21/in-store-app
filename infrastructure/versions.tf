terraform {

  backend "s3" {                                                                # Backend configuration using S3 bucket and DynamoDB Table for remote state storage.
    bucket         = "in-store-app-terraform-state-backend"                     # S3 bucket name
    key            = "infrastructure/modules/remote_backend/terraform.tfstate"  # Path to the state file in the bucket
    region         = "eu-west-2"                                                # Region of the S3 bucket
    dynamodb_table = "jd-dynamodb-terraform-state-lock-table"                   # DynamoDB Table name
    encrypt        = true                                                       # Enable encryption - this allows me to encrypt the state file.
  }

  required_providers {                                                          # Required providers block to specify the provider versions.
    aws = {                                                                     # AWS provider block to specify the source and version of the provider.
      source  = "hashicorp/aws"                                                 # Source of the provider
      version = "~> 4.0"                                                        # Version of the provider
    }
  }

  required_version = ">= 1.3.0"                                                 # Required version of Terraform
}



#------------------------- EXPLANATION -------------------------#
# S3 (Simple Storage Service) bucket is a cloud object storage service provided by AWS. Is like a virtual hard drive in the cloud.
# S3 bucket has unlimited storage capacity, high availability (99.999999999%), has built-in versioning, and can be encrypted.
# In my case S3 bucket will store my terraform state file (terraform.tfstate) remotely to enable team collaboration, to prevent state file conflicts, to prevent local state file loss, maintain state history and secure sensitive information.
# When a user runs terraform apply or terraform destroy, the state file will be updated in the S3 bucket (by default only the most recent state file is shown but we can see all version by selecting the 'Show version' toggle on AWS console).

# DynamoDB Table is a fully managed NoSQL database service provided by AWS. It provides fast and predictable performance with seamless scalability.
# In my case DynamoDB Table will be used to lock the state file in the S3 bucket to prevent concurrent state file modifications. Avoids race conditions when multiple team members run terraform.
# When a user runs terraform apply or terraform destroy, the state file is locked in the DynamoDB Table to prevent other users from modifying the state file at the same time.

# So in summary, S3 stores the state file and DynamoDB prevents concurrent access.
# This combination is AWS's recommended pattern for remote state management.
# Both services offer high availability and durability and both support encryption for security.