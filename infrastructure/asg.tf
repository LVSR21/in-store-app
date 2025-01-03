####################################################
## Create Auto-Scaling Group linked with main VPC ##
####################################################

resource "aws_autoscaling_group" "ecs_autoscaling_group" {
  name                  = "${var.namespace}_ASG_${var.environment}" # Name of the Auto-Scaling Group
  max_size              = var.autoscaling_max_size                  # Maximum number of instances in the Auto-Scaling Group
  min_size              = var.autoscaling_min_size                  # Minimum number of instances in the Auto-Scaling Group
  desired_capacity      = var.autoscaling_desired_capacity          # Desired number of instances in the Auto-Scaling Group
  vpc_zone_identifier   = aws_subnet.private.*.id                   # List of private subnet IDs to launch resources in
  health_check_type     = "EC2"                                     # Type of health check to perform
  protect_from_scale_in = true                                      # Allows setting instance protection

  enabled_metrics = [                                               # List of metrics to collect
    "GroupMinSize",                                                 # Minimum number of instances in the Auto-Scaling Group
    "GroupMaxSize",                                                 # Maximum number of instances in the Auto-Scaling Group
    "GroupDesiredCapacity",                                         # Desired number of instances in the Auto-Scaling Group
    "GroupInServiceInstances",                                      # Number of instances in service
    "GroupPendingInstances",                                        # Number of instances in pending state
    "GroupStandbyInstances",                                        # Number of instances in standby state
    "GroupTerminatingInstances",                                    # Number of instances in terminating state
    "GroupTotalInstances"                                           # Total number of instances in the Auto-Scaling Group
  ]

  launch_template {                                                 # Launch template configuration to use
    id      = aws_launch_template.ecs_launch_template.id            # ID of the launch template
    version = "$Latest"                                             # Version of the launch template
  }

  instance_refresh {                                                # Instance refresh configuration
    strategy = "Rolling"                                            # Strategy to use for instance refresh. Gradually replace instances in ASG, maintain application availability during updates and minimizes downtime. Replaces instances in batches of 1.
  }

  lifecycle {                                                       # Lifecycle configuration to use
    create_before_destroy = true                                    # Create new instances before terminating old ones
  }

  tag { 
    key                 = "Name"
    value               = "${var.namespace}_ASG_${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Scenario"
    propagate_at_launch = false
    value               = var.scenario
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = "ecs-instance"
    propagate_at_launch = true
  }
}



# ------------------------- EXPLANATION ------------------------- #
# Auto-Scaling Group (ASG) automatically manages EC2 instances.
# ASG ensures that a specified number of instances are running at all times.
# The ASG manages ECS container instances in the ECS cluster with automated scaling and hight availability features.