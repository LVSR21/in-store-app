##################################################
# Retrieve the ECR repository using data source ##
##################################################

data "aws_ecr_repository" "ecr_repo" {
  name = "jd-repo" # The name of the ECR repository.
}



#------------------------- EXPLANATION -------------------------#
# ECR (Elastic Container Registry) is a fully-managed Docker container registry that makes it easy for developers to store, manage, and deploy Docker container images.