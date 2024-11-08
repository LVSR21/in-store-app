output "alb_name" {
  description = "ALB Name."
  value       = aws_lb.alb.name
}

output "alb_dns_name" {
  description = "ALB DNS name."
  value       = aws_lb.alb.dns_name
}

output "alb_zone_id" {
  description = "ALB Zone ID."
  value       = aws_lb.alb.zone_id
}

output "alb_target_group_arn" {
  description = "ALB Target Group ARN."
  value       = aws_lb_target_group.alb_target_group.arn
}

output "alb_certificate_domain_validation_options" {
  description = "ALB Certificate Domain Validation Options."
  value = aws_acm_certificate.alb_certificate.domain_validation_options
}