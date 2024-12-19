########################################################
# Retrieve the ECR repository using data source
########################################################

data "aws_ecr_repository" "ecr_repo" {
  name = "jd-repo"
}


output "ecr_repository_url" {
  value = data.aws_ecr_repository.ecr_repo.repository_url
}