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
    description = "Environment name."
    type    = string
    default = "Prod"
}


#---------------------------------------
# Region variable
#---------------------------------------
variable "aws_region" {
    description = "AWS region."
    type    = string
    default = "eu-west-2"
}


#---------------------------------------
# MongoDB Connection Sring variable
#---------------------------------------
variable "mongodb_connection_string" {
    description = "MongoDB connection string for the api container."
    type = string
    sensitive = true
}


#---------------------------------------
# CloudFlare API Token variable
#---------------------------------------
variable "cloudflare_api_token" {
    description = "CloudFlare API Token."
    type = string
    sensitive = true
}