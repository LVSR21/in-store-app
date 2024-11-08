##################################################
# ECR Repository
##################################################
resource "aws_ecr_repository" "ecr" {
    name = "${var.project_name}-${var.environment}-ecr"
    image_tag_mutability = "MUTABLE" # IMPORTANT: This must be changed to "IMMUTABLE" when deploying to Production.
    
    image_scanning_configuration {
        scan_on_push = true
    }
    
    tags = {
        Name = "${var.project_name}-${var.environment}-ecr"
    }
}