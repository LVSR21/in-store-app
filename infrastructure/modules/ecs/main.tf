####################################################
# ECS cluster
####################################################
resource "aws_ecs_cluster" "ecs_cluster" {
    name = "${var.project_name}-${var.environment}-ecs-cluster"

    lifecycle {
        create_before_destroy = true
    }
    
    tags = {
    "Name" = "${var.project_name}-${var.environment}-ecs-cluster"
    }
}

####################################################
# ECS Service that will run the task
####################################################
resource "aws_ecs_service" "ecs_service" {
    name                               = "${var.project_name}-${var.environment}-ecs-service"
    iam_role                           = aws_iam_role.ecs_service_role.arn
    cluster                            = aws_ecs_cluster.ecs_cluster.id
    task_definition                    = aws_ecs_task_definition.ecs_task_definition.arn
    desired_count                      = 4 # IMPORTANT: This must be ignored for Production when using auto-scaling.
    deployment_minimum_healthy_percent = 50 # How many percent of a service must be running to still execute a safe deployment.
    deployment_maximum_percent         = 100 # How many additional tasks are allowed to run (in percent) while a deployment is executed.

    # Load Balancer configuration
    load_balancer {
        target_group_arn = var.alb_target_group_arn
        container_name   = "nginx" # The name of the container running the Nginx service
        container_port   = 80 # The internal port where Nginx is listening
    }

    # Spread tasks evenly accross all Availability Zones for High Availability
    ordered_placement_strategy {
        type  = "spread" # This ensures that tasks are spread evenly across all Availability Zones. In case of a failure of one AZ, a backup is still available and the service can be guaranteed without interruption.
        field = "attribute:ecs.availability-zone"
    }

    # Make use of all available space on the Container Instances
    ordered_placement_strategy {
        type  = "binpack" # I use binpack method to make use of all available space on the container instances
        field = "memory"
    }

    # Triggers redeployment of the service when I want to force a new deployment
    # Useful when container configuration changes but task definition version remains the same
    triggers = {
        redeployment = timestamp()
    }

    # Capacity Provider Strategy
    capacity_provider_strategy {
        capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
        weight            = 100
    }

    lifecycle {
        ignore_changes = [ desired_count ] # IMPORTANT: This must be ignored for Production when using auto-scaling.
    }

    tags = {
        "Name" = "${var.project_name}-${var.environment}-ecs-service"
    }
}

#####################################################
# IAM - ECS Service Role Definition
#####################################################
resource "aws_iam_role" "ecs_service_role" {
    name               = "${var.project_name}-${var.environment}-ecs-service-role"
    assume_role_policy = data.aws_iam_policy_document.ecs_service_policy.json

    tags = {
        "Name" = "${var.project_name}-${var.environment}-ecs-service-role"
    }
}

######################################################################
# Fetch IAM - ECS Service Role Trust Policy Document
######################################################################
data "aws_iam_policy_document" "ecs_service_policy" {
    statement {
        actions = ["sts:AssumeRole"]
        effect  = "Allow"

        principals {
            type        = "Service"
            identifiers = ["ecs.amazonaws.com"]
        }
    }
}

######################################################################
# IAM - ECS Service Role Policy Attachment
######################################################################
resource "aws_iam_role_policy" "ecs_service_role_policy" {
    name   = "${var.project_name}-${var.environment}-ecs-service-role-policy"
    policy = data.aws_iam_policy_document.ecs_service_role_policy.json
    role   = aws_iam_role.ecs_service_role.id
}

######################################################################
# Fetch IAM - ECS Service Role Permissions Policy Document
######################################################################
data "aws_iam_policy_document" "ecs_service_role_policy" {
    statement {
        effect  = "Allow"
        actions = [
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:Describe*",
            "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
            "elasticloadbalancing:DeregisterTargets",
            "elasticloadbalancing:Describe*",
            "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
            "elasticloadbalancing:RegisterTargets",
            "ec2:DescribeTags",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogStreams",
            "logs:PutSubscriptionFilter",
            "logs:PutLogEvents"
        ]
        resources = ["*"]
    }
}

####################################################
# ECS Task Definition
####################################################
resource "aws_ecs_task_definition" "ecs_task_definition" {
    family             = "${var.project_name}-${var.environment}-ecs-task-definition"
    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
    task_role_arn      = aws_iam_role.ecs_task_iam_role.arn
    
    network_mode       = "bridge" # Use bridge for EC2 launch type - DOUBLE CHECK THIS

    runtime_platform {
        operating_system_family = "LINUX" # DOUBLE CHECK THIS
        cpu_architecture        = "X86_64" # DOUBLE CHECK THIS
    }

    container_definitions = jsonencode([
    {
        name      = "nginx"
        image     = "${var.ecr_repository_url}/nginx:latest" # My nginx image
        cpu       = 100 # Amount of CPU units for a single ECS task
        memory    = 256 # Amount of memory in MB for a single ECS task
        essential = true
        portMappings = [
        {
            containerPort = 80
            hostPort      = 0 # Dynamically assign a port
            protocol      = "tcp"
        }
        ]
        links = ["client", "api"] # Links to other containers
        logConfiguration = {
            logDriver = "awslogs"
            options = {
                "awslogs-group"         = var.cloudwatch_log_group_name
                "awslogs-region"        = var.aws_region
                "awslogs-stream-prefix" = "nginx"
            }
        }
    },
    {
        name      = "client"
        image     = "${var.ecr_repository_url}/client:latest" # My client image
        cpu       = 256
        memory    = 512
        essential = true
        portMappings = [
        {
            containerPort = 3000 # Matches my Nginx upstream configuration
            protocol      = "tcp"
        }
        ]
        environment = [
            {
                name  = "WDS_SOCKET_PORT"  # From your docker-compose
                value = "0"
            }
        ]
        logConfiguration = {
            logDriver = "awslogs"
            options = {
                "awslogs-group"         = var.cloudwatch_log_group_name
                "awslogs-region"        = var.aws_region
                "awslogs-stream-prefix" = "client"
            }
        }
    },
    {
        name      = "api" # From Docker-Compose file
        image     = "${var.ecr_repository_url}/api:latest" # My api image
        cpu       = 256
        memory    = 512
        essential = true
        portMappings = [
        {
            containerPort = 5000 # Matches my Nginx upstream configuration
            protocol      = "tcp"
        }
        ]
        environment = [
            {
                name  = "NODE_ENV"
                value = "production"
            },
            {
                name  = "PORT"
                value = "5000"
            }
        ]
        secrets = [
            {
                name      = "mongodb_connection_string"
                valueFrom = var.mongodb_secret_arn
            }
        ]
        logConfiguration = {
            logDriver = "awslogs"
            options = {
                "awslogs-group"         = var.cloudwatch_log_group_name
                "awslogs-region"        = var.aws_region
                "awslogs-stream-prefix" = "api"
            }
        }
    }
    ])

    tags = {
        "Name" = "${var.project_name}-${var.environment}-ecs-task-definition"
    }
}

####################################################
# IAM - ECS Task Execution Role Definition
####################################################
resource "aws_iam_role" "ecs_task_execution_role" {
    name               = "${var.project_name}-${var.environment}-ecs-task-execution-role"
    assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role_policy.json
}

########################################################################
# Fetch IAM - ECS Task Execution Role Trust Policy Document
########################################################################
data "aws_iam_policy_document" "ecs_task_execution_assume_role_policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ecs-tasks.amazonaws.com"]
        }
    }
}

####################################################
# IAM - ECS Task Execution Role Policy Attachment
####################################################
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
    role       = aws_iam_role.ecs_task_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

###################################################################################################
# IAM - Attach Secrets Policy to ECS Task Execution Role
# ---------------------------------------------------------
# This is needed because the execution role is responsible for injecting secrets into containers
###################################################################################################
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_secrets_policy" {
    role       = aws_iam_role.ecs_task_execution_role.name
    policy_arn = var.mongodb_secrets_policy_arn
}

####################################################
# IAM - ECS Task Role Definition
####################################################
resource "aws_iam_role" "ecs_task_iam_role" {
    name               = "${var.project_name}-${var.environment}-ecs-task-iam-role"
    assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role_policy.json
}

####################################################
# IAM - Attach Secrets Policy to ECS Task Role
####################################################
resource "aws_iam_role_policy_attachment" "ecs_task_role_secrets_policy" {
    role       = aws_iam_role.ecs_task_iam_role.name
    policy_arn = var.mongodb_secrets_policy_arn
}

####################################################
# ECS Capacity Provider
####################################################
resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
    name = "${var.project_name}-${var.environment}-ecs-capacity-provider"

    auto_scaling_group_provider {
        auto_scaling_group_arn         = var.auto_scaling_group_arn
        managed_termination_protection = "ENABLED" # Prevents EC2 Instances from being terminated on which other ECS tasks are running

        managed_scaling {
            maximum_scaling_step_size = 5 # Maximum amount of EC2 instances that should be added on scale-out
            minimum_scaling_step_size = 1 # Minimum amount of EC2 instances that should be added on scale-out
            status                    = "ENABLED"
            target_capacity           = 100 # Amount of resources of container instances that should be used for task placement in %
        }
    }
}

####################################################
# ECS Cluster Capacity Provider
####################################################
resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_provider" {
    cluster_name       = aws_ecs_cluster.ecs_cluster.name
    capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]
}

#####################################################################################################################################################
# ECS Service Auto Scaling Target
# --------------------------------------------------
# Service Autoscaling handles elastic scaling of containers (ECS Tasks) and also works in my setup using Target Tracking for CPU and Memory usage. 
#####################################################################################################################################################
resource "aws_appautoscaling_target" "ecs_target" {
    max_capacity       = 10 # How many ECS tasks should maximally run in parallel
    min_capacity       = 2 # How many ECS tasks should minimally run in parallel
    resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
    scalable_dimension = "ecs:service:DesiredCount"
    service_namespace  = "ecs"
}

####################################################
# ECS Service Policy for CPU Tracking
####################################################
resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
    name               = "${var.project_name}-${var.environment}-CPU-target-tracking-scaling"
    policy_type        = "TargetTrackingScaling"
    resource_id        = aws_appautoscaling_target.ecs_target.resource_id
    scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
    service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

    target_tracking_scaling_policy_configuration {
        target_value = 70 # Target tracking for CPU usage in %

        predefined_metric_specification {
            predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
    }
}

####################################################
# ECS Service Policy for Memory Tracking
####################################################
resource "aws_appautoscaling_policy" "ecs_memory_policy" {
    name               = "${var.project_name}-${var.environment}-Memory-target-tracking-scaling"
    policy_type        = "TargetTrackingScaling"
    resource_id        = aws_appautoscaling_target.ecs_target.resource_id
    scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
    service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

    target_tracking_scaling_policy_configuration {
        target_value = 80 # Target tracking for Memory usage in %
        
        predefined_metric_specification {
            predefined_metric_type = "ECSServiceAverageMemoryUtilization"
        }
    }
}
