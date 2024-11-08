#---------------------------------------
# Project naming variable
#---------------------------------------
variable "project_name" {
  description = "Project name."
  type        = string
  default     = "in-store-app"
}

#---------------------------------------
# Environment variable
#---------------------------------------
variable "environment" {
  description = "Environment for deployment."
  type        = string
  default     = "Staging" # Change to "Production" when deploying to production
}

#---------------------------------------
# AWS Access Key ID variable
#---------------------------------------
variable "aws_access_key_id" {
  description = "AWS access key ID."
  type        = string
}

#---------------------------------------
# AWS Secret Access Key variable
#---------------------------------------
variable "aws_secret_access_key" {
  description = "AWS secret access key."
  type        = string
}

#---------------------------------------
# Region variables
#---------------------------------------
variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "eu-west-2"
}

#---------------------------------------
# Route 53 variable
#---------------------------------------
variable "domain_name" {
  description = "Domain name."
  type    = string
  default = "in-store-app.co.uk"
}

#---------------------------------------
# Network variables
#---------------------------------------
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC network."
  type        = string
  default     = "10.0.0.0/16"
}

variable "all_traffic" {
  description = "CIDR block to allow all traffic."
  type        = string
  default     = "0.0.0.0/0"
}

#---------------------------------------
# EC2 variables
#---------------------------------------
variable "ec2_instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t2.micro"
}

variable "instance_key_pair" {
  description = "EC2 instance key pair name."
  type        = string
  default     = "in-store-app-key-pair" # Please note that this key pair already exists in my AWS account under 'key pair' section in the eu-west-2 region (London).
}

#---------------------------------------
# ALB/CloudFront variable
#---------------------------------------
variable "cloudfront_origin_secret" {
  description = "CloudFront origin secret to be used to authenticate with the ALB."
  type        = string
}

#---------------------------------------
# MongoDB Connection String variable
#---------------------------------------
variable "mongodb_connection_string" {
  description = "MongoDB connection string for the api container."
  type        = string
}

#---------------------------------------
# OpenVPN IP variable
#---------------------------------------
variable "open_vpn_ip" {
  description = "OpenVPN server's IP."
  type        = string
}
