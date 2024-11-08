############################################################
# Create MongoDB secret
############################################################
resource "aws_secretsmanager_secret" "mongodb" {
    name = "${var.project_name}-${var.environment}-mongodb-connection-string"
    description = "MongoDB connection string for the api container."

    tags = {
        "Name" = "${var.project_name}-${var.environment}-mongodb-connection-string"
    }
}

############################################################
# Store MongoDB secret version
############################################################
resource "aws_secretsmanager_secret_version" "mongodb" {
    secret_id = aws_secretsmanager_secret.mongodb.id
    secret_string = var.mongodb_connection_string
}

############################################################
# Policy to allow ECS to read secrets (MongoDB)
############################################################
resource "aws_iam_policy" "mongodb_secrets_policy" {
    name = "mongodb-secrets-policy"
    description = "IAM policy to allow ECS to read MongoDB secret from Secrets Manager."

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Action = [
                    "secretsmanager:GetSecretValue",
                    "secretsmanager:DescribeSecret"
                ],
                Resource = [
                    aws_secretsmanager_secret.mongodb.arn
                ]
            }
        ]
    })
}

############################################################
# Create CloudFront secret
############################################################
resource "aws_secretsmanager_secret" "cloudfront" {
    name = "${var.project_name}-${var.environment}-cloudfront-origin-secret"
    description = "CloudFront origin secret for ALB."

    tags = {
        "Name" = "${var.project_name}-${var.environment}-cloudfront-origin-secret"
    }
}

############################################################
# Store CloudFront secret version
############################################################
resource "aws_secretsmanager_secret_version" "cloudfront" {
    secret_id = aws_secretsmanager_secret.cloudfront.id
    secret_string = var.cloudfront_origin_secret
}

##############################################################################
# Policy to allow EC2 behind ALB to read secrets (CloudFront origin secret)
##############################################################################
resource "aws_iam_policy" "cloudfront_secrets_policy" {
    name = "cloudfront-secrets-policy"
    description = "IAM policy to access CloudFront origin secret from Secrets Manager."

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Action = [
                    "secretsmanager:GetSecretValue",
                    "secretsmanager:DescribeSecret"
                ],
                Resource = [
                    aws_secretsmanager_secret.cloudfront.arn
                ]
            }
        ]
    })
}