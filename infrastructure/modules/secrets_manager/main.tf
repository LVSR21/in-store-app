############################################################
# MongoDB secret in AWS Secrets Manager
############################################################
resource "aws_secretsmanager_secret" "mongodb" {
    description = "MongoDB connection string for the api container."
    name = "mongodb-connection-string"
}

############################################################
# MongoDB secret version in AWS Secrets Manager
############################################################
resource "aws_secretsmanager_secret_version" "mongodb" {
    secret_id = aws_secretsmanager_secret.mongodb.id
    secret_string = var.mongodb_connection_string
}

############################################################
# CloudFlare secret in AWS Secrets Manager
############################################################
resource "aws_secretsmanager_secret" "cloudflare" {
    description = "CloudFlare API token for the nginx container."
    name = "cloudflare-api-token"
}

############################################################
# CloudFlare secret version in AWS Secrets Manager
############################################################
resource "aws_secretsmanager_secret_version" "cloudflare" {
    secret_id = aws_secretsmanager_secret.cloudflare.id
    secret_string = var.cloudflare_api_token
}

############################################################
# Policy to allow ECS to read secrets
############################################################
resource "aws_iam_policy" "secrets_policy" {
    name = "ecs-secrets-policy"
    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Action = [
                    "secretsmanager:GetSecretValue"
                ],
                Resource = [
                    aws_secretsmanager_secret.mongodb.arn,
                    aws_secretsmanager_secret.cloudflare.arn
                ]
            }
        ]
    })
}