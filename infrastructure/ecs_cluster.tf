########################
## Create ECS Cluster ##
########################

resource "aws_ecs_cluster" "default" {
  name = "${var.namespace}_ECSCluster_${var.environment}" # Name of the ECS Cluster

  tags = {
    Name     = "${var.namespace}_ECSCluster_${var.environment}"
    Scenario = var.scenario
  }
}



#------------------------- EXPLANATION -------------------------#
# ECS (Elastic Container Service) Cluster is an AWS service that acts as a logical grouping of EC2 instances.
# ECS Cluster is used to run and manage container orchestration and deployment.
# ECS Cluster manages container health, scaling, and scheduling.
# ECS Cluster integrates with Load Balancers and connects with CloudWatch for monitoring.