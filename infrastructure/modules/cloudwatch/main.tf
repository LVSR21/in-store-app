####################################################
# CloudWatch Log Group
####################################################
resource "aws_cloudwatch_log_group" "log" {
    name              = "${var.project_name}-${var.environment}-ecs-logs"
    retention_in_days = 7 # Retention period for Cloudwatch logs
}