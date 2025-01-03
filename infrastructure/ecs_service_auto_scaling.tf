#######################################################
## Create ECS Service Auto Scaling Target Definition ##
#######################################################

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.ecs_task_max_count                                                     # Maximum number of tasks
  min_capacity       = var.ecs_task_min_count                                                     # Minimum number of tasks
  resource_id        = "service/${aws_ecs_cluster.default.name}/${aws_ecs_service.service.name}"  # ECS service resource ID - in here I am are using the ECS service name and ECS cluster name
  scalable_dimension = "ecs:service:DesiredCount"                                                 # ECS service scalable dimension - in here I am using the desired count (desired count is the number of tasks that should be running in the service)
  service_namespace  = "ecs"                                                                      # ECS service namespace
}


#############################################################
## Create ECS Service Auto Scaling Policy for CPU tracking ##
#############################################################

resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
  name               = "${var.namespace}_CPUTargetTrackingScaling_${var.environment}" # Name of the policy
  policy_type        = "TargetTrackingScaling"                                        # Policy type -  this policy type is used to track a specific metric and adjust the desired count of the ECS service based on the metric (CPU in this case)
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id               # ECS service resource ID - in here I am using the ECS Target resource ID
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension        # ECS service scalable dimension -  in here I am using the ECS Target scalable dimension (scalable dimension is the ECS service attribute that is being tracked)
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace         # ECS service namespace -  in here I am using the ECS Target service namespace (service namespace is the namespace of the service that is being tracked)

  target_tracking_scaling_policy_configuration {                                      # Configuration for the target tracking scaling policy
    target_value = var.cpu_target_tracking_desired_value                              # Desired value for the metric

    predefined_metric_specification {                                                 # Predefined metric specification configuration
      predefined_metric_type = "ECSServiceAverageCPUUtilization"                      # Predefined metric type - in here I am using the average CPU utilization of the ECS service
    }
  }
}


################################################################
## Create ECS Service Auto Scaling Policy for Memory tracking ##
################################################################

resource "aws_appautoscaling_policy" "ecs_memory_policy" {
  name               = "${var.namespace}_MemoryTargetTrackingScaling_${var.environment}"  # Name of the policy
  policy_type        = "TargetTrackingScaling"                                            # Policy type - this policy type is used to track a specific metric and adjust the desired count of the ECS service based on the metric (Memory in this case)
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id                   # ECS service resource ID - in here I am using the ECS Target resource ID
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension            # ECS service scalable dimension -  in here I am using the ECS Target scalable dimension (scalable dimension is the ECS service attribute that is being tracked)
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace             # ECS service namespace -  in here I am using the ECS Target service namespace (service namespace is the namespace of the service that is being tracked)

  target_tracking_scaling_policy_configuration {                                          # Configuration for the target tracking scaling policy
    target_value = var.memory_target_tracking_desired_value                               # Desired value for the metric

    predefined_metric_specification {                                                     # Predefined metric specification configuration
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"                       # Predefined metric type - in here I am using the average memory utilization of the ECS service
    }
  }
}



#------------------------- EXPLANATION -------------------------#
# ECS Service Auto Scaling is a feature of ECS that automatically adjust the number of tasks (containers) running in my ECS service based on the metrics specified. 
# In this case, I am using the CPU and Memory metrics to adjust the number of tasks in the ECS service. 
# The ECS Service Auto Scaling feature is implemented using the AWS App Autoscaling service. 
# The AWS App Autoscaling service allows me to define scaling policies that adjust the desired count of the ECS service based on the metric that I specified. 
# In this case, I am defining two scaling policies, one for CPU tracking and one for Memory tracking. 
# The CPU tracking policy adjusts the desired count of the ECS service based on the average CPU utilization of the ECS service, while the Memory tracking policy adjusts the desired count of the ECS service based on the average memory utilization of the ECS service. 
# The ECS Service Auto Scaling feature is useful for automatically adjusting the number of tasks in my ECS service based on the workload and resource utilization of the service. 
# The ECS Service Auto Scaling feature helps to ensure that my ECS service is always running at the optimal capacity and can handle the workload efficiently.
# The ECS Service Auto Scaling feature prevents memory related crashes, maintains responsive application performance and handles traffic spikes automatically.
# The ECS Service Auto Scaling feature helps cost optimisation as it scales down during low usage (this helps to avoid over provisioning).
# The ECS Service Auto Scaling feature reduces manual intervention and provides automated 24/7 monitoring and scaling of the ECS service.