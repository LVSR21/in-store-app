output "cloudwatch_log_group_name" {
    description = "CloudWatch Log Group Name."
    value = aws_cloudwatch_log_group.log.name
}