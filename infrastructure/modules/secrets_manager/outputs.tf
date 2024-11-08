output "secrets_policy_arn" {
    description = "The ARN of the IAM policy that allows ECS to read secrets."
    value = aws_iam_policy.secrets_policy.arn
}

output "mongodb_secret_arn" {
    description = "The ARN of the MongoDB secret in AWS Secrets Manager."
    value = aws_secretsmanager_secret.mongodb.arn
}

output "mongodb_secrets_policy_arn" {
    description = "The ARN of the IAM policy that allows ECS to read secrets (MongoDB)."
    value = aws_iam_policy.secrets_policy.arn
}

output "cloudfront_secrets_policy_arn" {
    description = "The ARN of the CloudFront secret in AWS Secrets Manager."
    value       = aws_iam_policy.cloudfront_secrets_policy.arn
}