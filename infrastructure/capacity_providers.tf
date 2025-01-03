##############################################################
## Create Capacity Provider linked with ASG and ECS Cluster ##
##############################################################

resource "aws_ecs_capacity_provider" "cas" {
  name = "${var.namespace}_ECS_CapacityProvider_${var.environment}"                   # Name of the Capacity Provider

  auto_scaling_group_provider {                                                       # Configuration for the Auto Scaling Group Provider
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_autoscaling_group.arn  # ARN of the Auto Scaling Group
    managed_termination_protection = "ENABLED"                                        # Enable termination protection - this prevents instances in an ASG from being terminated if they are running ECS Tasks. This helps to maintain application availability by ensuring containers aren't abruptly stopped.

    managed_scaling {                                                                 # Configuration for Managed Scaling
      maximum_scaling_step_size = var.maximum_scaling_step_size                       # Maximum scaling step size
      minimum_scaling_step_size = var.minimum_scaling_step_size                       # Minimum scaling step size
      status                    = "ENABLED"                                           # Enable Managed Scaling - this controls whether the capacity provider is active or not. In this case is active and can be used. ECS can launch tasks using this capacity provider.
      target_capacity           = var.target_capacity                                 # Target capacity
    }
  }

  tags = {
    Scenario = var.scenario
  }
}


#############################################
## Attach Capacity Provider to ECS Cluster ##
#############################################

resource "aws_ecs_cluster_capacity_providers" "cas" {
  cluster_name       = aws_ecs_cluster.default.name         # Name of the ECS Cluster
  capacity_providers = [aws_ecs_capacity_provider.cas.name] # Attach the Capacity Provider to the ECS Cluster
}



#------------------------- EXPLANATION -------------------------#
# Capacity Provider acts as a link between ECS Cluster and Auto-Scaling Group and is linked to both resources.
# Capacity Providers calculate the required infrastructure for ECS Task container and Container Instances (EC2 instances) based on variables such as virtual CPU or memory.
# Capacity Providers take care of scaling out and scaling in of both components on demand by means of a Target Tracking Policy with a target value for CPU and/or memory usage.