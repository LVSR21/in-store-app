output "secrets_policy_arn" {
    description = "The ARN of the IAM policy that allows ECS to read secrets."
    value = aws_iam_policy.secrets_policy.arn
}

output "mongodb_secret_arn" {
    description = "The ARN of the MongoDB secret in AWS Secrets Manager."
    value = aws_secretsmanager_secret.mongodb.arn
}

output "cloudflare_secret_arn" {
    description = "The ARN of the CloudFlare secret in AWS Secrets Manager."
    value = aws_secretsmanager_secret.cloudflare.arn
}

