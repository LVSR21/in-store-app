############################################################
# MongoDB variables
############################################################
variable "mongodb_connection_string" {
    description = "MongoDB connection string for the api container."
    type = string
    sensitive = true
}

############################################################
# CloudFlare variables
############################################################
variable "cloudflare_api_token" {
    description = "CloudFlare API token for the nginx container."
    type = string
    sensitive = true
}