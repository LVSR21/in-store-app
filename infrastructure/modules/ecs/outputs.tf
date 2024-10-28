output "alb_target_group_arn" {
    description = "ALB Target Group ARN."
    value = aws_lb_target_group.alb_target_group.arn
}

output "ecr_repository_url" {
    description = "ECR repository URL."
    value = data.aws_ecr_repository.repo.repository_url
}