#######################
# AWS provider setup ##
#######################

provider "aws" {
  alias      = "main"
  region     = var.region
}

provider "aws" {
  alias      = "us_east_1"
  region     = "us-east-1"
}



#------------------------- EXPLANATION -------------------------#
# AWS Providers are the connection configuration that tells Terraform how to interact with AWS services.
# They authenticate and specify which AWS region to use for resource creation.
# In my case I have two providers, one for the main region and another for the us-east-1 region (for the CloudFront certificates).