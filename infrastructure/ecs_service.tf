########################################################################################################################
## Creates ECS Service
########################################################################################################################

resource "aws_ecs_service" "service" {
  name                               = "${var.namespace}_ECS_Service_${var.environment}"
  iam_role                           = aws_iam_role.ecs_service_role.arn
  cluster                            = aws_ecs_cluster.default.id
  task_definition                    = aws_ecs_task_definition.default.arn
  desired_count                      = var.ecs_task_desired_count
  deployment_minimum_healthy_percent = var.ecs_task_deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.ecs_task_deployment_maximum_percent

  # network_configuration {
  #   subnets         = aws_subnet.private[*].id
  #   security_groups = [aws_security_group.ec2.id]
  # }

  load_balancer {
    target_group_arn = aws_alb_target_group.service_target_group.arn
    container_name   = "nginx" # The name of the container running the Nginx service
    container_port   = 80      # The internal port where Nginx is listening
  }

  # Spread tasks evenly accross all Availability Zones for High Availability
  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  # Make use of all available space on the Container Instances
  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }

  # Do not update desired count again to avoid a reset to this number on every deployment
  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [
    aws_alb.alb,
    aws_alb_listener.alb_default_listener_https,
    aws_alb_listener_rule.https_listener_rule,
    aws_alb_target_group.service_target_group
    ]

  tags = {
    Scenario = var.scenario
  }
}

output "ecs_service_name" {
  value = aws_ecs_service.service.name
}