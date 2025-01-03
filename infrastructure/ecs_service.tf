############################################
## Create ECS Service for the ECS Cluster ##
############################################

resource "aws_ecs_service" "service" {
  name                               = "${var.namespace}_ECS_Service_${var.environment}"  # Name of the ECS Service
  iam_role                           = aws_iam_role.ecs_service_role.arn                  # IAM Role for the ECS Service
  cluster                            = aws_ecs_cluster.default.id                         # ECS Cluster where the Service will be deployed
  task_definition                    = aws_ecs_task_definition.default.arn                # Task Definition to use for the Service
  desired_count                      = var.ecs_task_desired_count                         # Number of tasks to run
  deployment_minimum_healthy_percent = var.ecs_task_deployment_minimum_healthy_percent    # Minimum healthy percent during a deployment
  deployment_maximum_percent         = var.ecs_task_deployment_maximum_percent            # Maximum percent during a deployment

  load_balancer {                                                     # Load Balancer configuration
    target_group_arn = aws_alb_target_group.service_target_group.arn  # Target Group to associate with the ECS Service
    container_name   = "nginx"                                        # The name of the container running the Nginx service
    container_port   = 80                                             # The internal port where Nginx is listening
  }

  ordered_placement_strategy {                # Placement Strategy configuration
    type  = "spread"                          # Spread the tasks evenly across all Availability Zones for High Availability
    field = "attribute:ecs.availability-zone" # Field to use for the spread - in this case the Availability Zone
  }

  ordered_placement_strategy {  # Placement Strategy configuration
    type  = "binpack"           # Pack the tasks based on the amount of resources they require. This make use of all available space on the Container Instances.
    field = "memory"            # Field to use for the binpack - in this case the memory
  }

  lifecycle {                         # Prevents the desired count from being updated
    ignore_changes = [desired_count]  # Ignore changes to the desired count -  do not update desired count again to avoid a reset to this number on every deployment
  }

  depends_on = [                                  # Ensure the following resources are created before the ECS Service
    aws_alb.alb,                                  # ALB
    aws_alb_listener.alb_default_listener_https,  # ALB Listener
    aws_alb_listener_rule.https_listener_rule,    # ALB Listener Rule
    aws_alb_target_group.service_target_group     # Target Group
    ]

  tags = {
    Scenario = var.scenario
  }
}



#------------------------- EXPLANATION -------------------------#
# ECS (Elastic Container Service) Service is a configuration that enables to run and maintain a specified number of instances of a task definition simultaneously in an ECS cluster.
# In my case ECS Service is responsible for maintaining the desired number of tasks (containers), to automatically re[;ace failed containers to maintain reliability and to run multi-container application (nginx, client and api) defined in my task definition.
# In my case ECS Service integrates with the ALB, routes traffic to my nginx container and enables high availability (spread tasks across multiple AZs) and scalability.
# In my case ECS Service efficiently packs tasks based on memory usage to make use of all available space on the Container Instances (binpack strategy).