output "in_store_app_cert_arn" {
  description = "The ARN of the SSL/TLS certificate."
  value       = aws_acm_certificate.in_store_app_cert.arn
}