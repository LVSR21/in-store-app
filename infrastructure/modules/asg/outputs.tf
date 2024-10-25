output "auto_scaling_group_arn" {
    description = "Auto Scaling Group ARN."
    value       = aws_autoscaling_group.asg.arn
}

output "auto_scaling_group_id" {
    description = "Auto Scaling Group ID."
    value       = aws_autoscaling_group.asg.id
}

