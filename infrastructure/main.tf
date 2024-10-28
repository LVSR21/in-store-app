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
      source = "cloudflare/cloudflare"
      version = "~> 4.0" # To use the latest stable version
    }

    random = {
      source  = "hashicorp/random" # Useful to create random suffixes to resource names to avoid conflicts when deploying multiple instances of a resource, such as S3 buckets or security groups
      version = ">= 3.0"
    }
  }
}



#----------------------------------------
# REUSABLE MODULES
#----------------------------------------
module "alb" {
  source = "./modules/alb"
  vpc_id = module.vpc.vpc_id
  alb_security_group_id = module.sg.alb_security_group_id
  in_store_app_cert_arn = module.cloudflare.in_store_app_cert_arn
  public_subnets = module.network.public_subnets
}

module "asg" {
  source = "./modules/asg"
  ec2_launch_template = module.ec2.ec2_launch_template
  ec2_launch_template_id = module.ec2.ec2_launch_template_id
  private_subnets = module.network.private_subnets
}

module "bastion" {
  source = "./modules/bastion"
  bastion_security_group_id = module.asg.bastion_security_group_id
  id_of_first_public_subnet = module.network.id_of_first_public_subnet
}

module "cloudflare" {
  source = "./modules/cloudflare"
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id = module.alb.alb_zone_id
}

module "ec2" {
  source = "./modules/ec2"
  bastion_security_group_id = module.sg.bastion_security_group_id
  ec2_security_group_id = module.sg.ec2_security_group_id
  alb_security_group_id = module.sg.alb_security_group_id
}

module "ecs" {
  source = "./modules/ecs"
  alb_target_group_arn = module.alb.alb_target_group_arn
  ecr_repository_url = module.ecr.ecr_repository_url
  secrets_policy_arn = module.secrets_manager.secrets_policy_arn
  auto_scaling_group_arn = module.asg.auto_scaling_group_arn
  mongodb_secret_arn = module.secrets_manager.mongodb_secret_arn
  cloudflare_secret_arn = module.secrets_manager.cloudflare_secret_arn
}

module "network" {
  source = "./modules/network"
  aws_vpc = module.vpc.aws_vpc
  vpc_id = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
}

module "remote_backend" {
  source = "./modules/remote_backend"
}

module "secrets_manager" {
  source = "./modules/secrets_manager"
  mongodb_connection_string = var.mongodb_connection_string
  cloudflare_api_token = var.cloudflare_api_token
}

module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
  vpc_endpoint_s3 = module.vpc.vpc_endpoint_s3
  private_subnets_cidr_blocks = module.network.private_subnets_cidr_blocks
}

module "vpc" {
  source = "./modules/vpc"
  vpc_endpoints_security_group_id = module.sg.vpc_endpoints_security_group_id
  private_subnets = module.network.private_subnets
  private_route_table_id = module.network.private_route_table_id
}