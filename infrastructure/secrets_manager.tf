############################################################
# Create MongoDB secret
############################################################
resource "aws_secretsmanager_secret" "mongodb" {
  name        = "${var.namespace}-mongodb-connection-string-${var.environment}"
  description = "MongoDB connection string for the api container."

  tags = {
    Name = "${var.namespace}_mongodb-connection-string_${var.environment}"
  }
}

############################################################
# Store MongoDB secret version
############################################################
resource "aws_secretsmanager_secret_version" "mongodb" {
  secret_id     = aws_secretsmanager_secret.mongodb.id
  secret_string = var.mongodb_connection_string
}

############################################################
# Data source to read the MongoDB secret value
############################################################
data "aws_secretsmanager_secret_version" "mongodb" {
  secret_id  = aws_secretsmanager_secret.mongodb.id
  depends_on = [aws_secretsmanager_secret_version.mongodb]
}

############################################################
# Policy to allow ECS to read secrets (MongoDB)
############################################################
resource "aws_iam_policy" "mongodb_secrets_policy" {
  name        = "mongodb-secrets-policy"
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
  name        = "${var.namespace}-cloudfront-origin-secret-${var.environment}"
  description = "CloudFront origin secret for ALB."

  tags = {
    Name = "${var.namespace}_cloudfront-origin-secret_${var.environment}"
  }
}

############################################################
# Store CloudFront secret value version
############################################################
resource "aws_secretsmanager_secret_version" "cloudfront" {
  secret_id     = aws_secretsmanager_secret.cloudfront.id
  secret_string = var.custom_origin_host_header
}

############################################################
# Data source to read the CloudFront secret value
############################################################
data "aws_secretsmanager_secret_version" "cloudfront" {
  secret_id = aws_secretsmanager_secret.cloudfront.id
  depends_on = [aws_secretsmanager_secret.cloudfront]
}

##############################################################################
# Policy to allow EC2 behind ALB to read secrets (CloudFront origin secret)
##############################################################################
resource "aws_iam_policy" "cloudfront_secrets_policy" {
  name        = "cloudfront-secrets-policy"
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