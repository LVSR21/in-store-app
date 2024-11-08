output "alb_certificate_arn" {
  description = "The ARN of the SSL/TLS certificate."
  value       = aws_acm_certificate.alb_certificate.arn
}

output "cloudfront_certificate_arn" {
  description = "The ARN of the SSL/TLS certificate."
  value       = aws_acm_certificate.cloudfront_certificate.arn
}

output "certificate_validation_records" {
  description = "The certificate validation records."
  value = aws_route53_record.certificate_validation_records
}