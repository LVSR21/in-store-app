####################################################
# Auto Scaling Group
####################################################
resource "aws_autoscaling_group" "asg" {
    min_size                  = 1
    max_size                  = 4
    desired_capacity          = 2
    vpc_zone_identifier       = tolist(var.private_subnets)
    health_check_type         = "EC2"
    protect_from_scale_in     = true
    
    enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
    ]

    launch_template {
    id      = var.ec2_launch_template_id
    version = var.ec2_launch_template.latest_version
    }

    instance_refresh {
        strategy = "Rolling"
        preferences {
            min_healthy_percentage = 90
            instance_warmup        = 300 # 5 minutes
        }
    }
    
    tag {
        key                 = "AmazonECSManaged"
        value               = true
        propagate_at_launch = true
    }

    tag {
        key                 = "Name"
        value               = "${var.project_name}-asg"
        propagate_at_launch = true
    }
}

#######################################################################################
# Auto Scaling Policy - if memory utilization is greater than 80% add more instances
#######################################################################################
resource "aws_autoscaling_policy" "asg_scaling_policy" {
    name                   = "${var.project_name}-asg-scaling-policy"
    policy_type            = "TargetTrackingScaling"
    autoscaling_group_name = aws_autoscaling_group.asg.name

    target_tracking_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ECSServiceAverageCPUUtilization" # Used CPU raher than memory to handle sudden user spikes
        }
        target_value     = 70 # A balanced target that gives room for sudden spikes
        disable_scale_in = false # Allows the ASG to both scale out (add instances) and scale in (remove instances) automatically.
    }
}