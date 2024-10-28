##########################################################
# S3 bucket to store the terraform state
##########################################################
resource "aws_s3_bucket" "terraform_state" {
    bucket = var.s3_bucket_name

    tags = {
        Name = "${var.project_name}-terraform-state"
    }
}

##########################################################
# S3 bucket versioning
##########################################################
resource "aws_s3_bucket_versioning" "enabled" {
    bucket = aws_s3_bucket.terraform_state.id

    versioning_configuration {
        status = "Enabled"
    }
}

##########################################################
# S3 bucket server side encryption
##########################################################
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
    bucket = aws_s3_bucket.terraform_state.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

##########################################################
# S3 bucket public access block
##########################################################
resource "aws_s3_bucket_public_access_block" "public_access" {
    bucket                  = aws_s3_bucket.terraform_state.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

##########################################################
# DynamoDB table to store the terraform locks
##########################################################
resource "aws_dynamodb_table" "terraform_locks" {
    name = var.dynamodb_table_name
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S" # String stands for S
    }

    tags = {
        Name = "${var.project_name}-terraform-locks"
    }
}