####################################################
# Auto Scaling Group
####################################################
resource "aws_autoscaling_group" "ecs_autoscaling_group" {
    name                      = "${var.project_name}-${var.environment}-asg"
    min_size                  = 2
    max_size                  = 6
    vpc_zone_identifier       = tolist(var.private_subnet_ids)
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
        version = "$Latest"
    }

    instance_refresh {
        strategy = "Rolling"
    }

    lifecycle {
        create_before_destroy = true
    }

    tag {
        key                 = "Name"
        value               = "${var.project_name}-${var.environment}-asg"
        propagate_at_launch = true
    }
}