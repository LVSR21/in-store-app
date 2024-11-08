variable "project_name" {
    type        = string
}

variable "environment" {
    type        = string
}

variable "domain_name" {
    type        = string
}

variable "cloudfront_origin_secret" {
    type        = string
}

# --------------------------------------------------
# MODULES OUTPUTS VARIABLES
# --------------------------------------------------

# --------------------------------------------------
# ALB Module outputs
# --------------------------------------------------
variable "alb_name" {
    description = "ALB Name."
    type        = string
}

variable "alb_dns_name" {
    description = "ALB DNS name."
    type        = string
}

# --------------------------------------------------
# Route 53 Module outputs
# --------------------------------------------------
variable "certificate_validation_records" {
    description = "The certificate validation records."
    type        = list(object({
        name    = string
        type    = string
        value   = string
    }))
}
