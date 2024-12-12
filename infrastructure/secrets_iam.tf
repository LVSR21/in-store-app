# Create IAM policy
resource "aws_iam_policy" "secrets_policy" {
  name = "ecs-secrets-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:eu-west-2:344615752961:secret:jd-mongodb-connection-string-prod-*"
        ]
      }
    ]
  })
}

# Attach policy to the task execution role
resource "aws_iam_role_policy_attachment" "secrets_policy_attachment" {
  role       = "jd_ECS_TaskExecutionRole_prod"
  policy_arn = aws_iam_policy.secrets_policy.arn
}