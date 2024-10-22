output "alb_dns_name" {
  description = "ALB DNS name."
  value       = aws_alb.alb.dns_name
}

output "alb_target_group_arn" {
  description = "ALB Target Group ARN."
  value       = aws_lb_target_group.alb_target_group.arn
}