####################################################
# Fetch the ECR repository
####################################################
data "aws_ecr_repository" "repo" {
    name = "in-store-app-repo"
}

####################################################
# ECS cluster
####################################################
resource "aws_ecs_cluster" "ecs_cluster" {
    name = var.ecs_cluster_name
    
    tags = {
    "Name" = "${var.project_name}-ecs-cluster"
    }
}

####################################################
# ECS Capacity Provider
####################################################
resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
    name = "capacity_provider"

    auto_scaling_group_provider {
        auto_scaling_group_arn         = var.auto_scaling_group_arn
        managed_termination_protection = "ENABLED"

    managed_scaling {
        maximum_scaling_step_size = 5
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 100
    }
    }
}

####################################################
# Create an ECS Cluster capacity Provider
####################################################
resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_provider" {
    cluster_name       = aws_ecs_cluster.ecs_cluster.name
    capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]
}

####################################################
# ECS Task Definition
####################################################
resource "aws_ecs_task_definition" "ecs_task_definition" {
    family             = "in-store-app-task"
    network_mode       = "bridge" # Use bridge for EC2 launch type
    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture        = "X86_64"
    }

    container_definitions = jsonencode([
    {
        name      = "nginx"
        image     = "${var.ecr_repository_url}/nginx:latest" # My nginx image
        cpu       = 128
        memory    = 128
        essential = true
        portMappings = [
        {
            containerPort = 80
            hostPort      = 0 # Dynamically assign a port
            protocol      = "tcp"
        }
        ]
        links = ["client", "api"]
        secrets = [
            {
                name      = "CLOUDFLARE_API_TOKEN"
                valueFrom = var.cloudflare_secret_arn
            }
        ]
        logConfiguration = {
            logDriver = "awslogs"
            options = {
                "awslogs-group"         = aws_cloudwatch_log_group.log.name
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
                "awslogs-group"         = aws_cloudwatch_log_group.log.name
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
                name      = "MONGODB_CONNECTION_STRING"
                valueFrom = var.mongodb_secret_arn
            }
        ]
        logConfiguration = {
            logDriver = "awslogs"
            options = {
                "awslogs-group"         = aws_cloudwatch_log_group.log.name
                "awslogs-region"        = var.aws_region
                "awslogs-stream-prefix" = "api"
            }
        }
    }
    ])
}

####################################################
# ECS Service that will run the task
####################################################
resource "aws_ecs_service" "ecs_service" {
    name = "in-store-app-service"
    cluster = aws_ecs_cluster.ecs_cluster.id
    task_definition = aws_ecs_task_definition.ecs_task_definition.arn
    desired_count = 4
    deployment_minimum_healthy_percent = 50
    deployment_maximum_percent = 100

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

    # Load Balancer configuration
    load_balancer {
        target_group_arn = var.alb_target_group_arn
        container_name   = "nginx"
        container_port   = 80
    }
}

####################################################
# ECS Service auto scaling target
####################################################
resource "aws_appautoscaling_target" "ecs_target" {
    max_capacity       = 30
    min_capacity       = 2
    resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
    scalable_dimension = "ecs:service:DesiredCount"
    service_namespace  = "ecs"
}

####################################################
# ECS Service auto scaling policy for Memory
####################################################
resource "aws_appautoscaling_policy" "ecs_policy_memory" {
    name               = "${var.project_name}-memory-autoscaling"
    policy_type        = "TargetTrackingScaling"
    resource_id        = aws_appautoscaling_target.ecs_target.resource_id
    scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
    service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ECSServiceAverageMemoryUtilization"
        }
        target_value = 80
    }
}

####################################################
# ECS Service auto scaling policy for CPU
####################################################
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
    name               = "${var.project_name}-cpu-autoscaling"
    policy_type        = "TargetTrackingScaling"
    resource_id        = aws_appautoscaling_target.ecs_target.resource_id
    scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
    service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
        predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
        target_value = 70
    }
}

################################################################
# Fetch Predefined IAM Policy for ECS Task Execution Role
################################################################
data "aws_iam_policy" "ecs_task_execution_role_policy" {
    arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy" # This is prefefined policy for ECS - please see IAM policies for more details.
}

################################################################
# Fetch IAM Policy Document for ECS Execution Role
################################################################
data "aws_iam_policy_document" "ecs_execution_role_policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ecs-tasks.amazonaws.com"]
        }
    }
}

#################################################################
# IAM Role for ECS Task Execution
#################################################################
resource "aws_iam_role" "ecs_task_execution_role" {
    name               = "ecsTaskExecutionRole"
    path               = "/"
    assume_role_policy = data.aws_iam_policy_document.ecs_execution_role_policy.json
}

#################################################################
# Attach IAM Policy to ECS Task Execution Role
#################################################################
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
    role       = aws_iam_role.ecs_task_execution_role.name
    policy_arn = data.aws_iam_policy.ecs_task_execution_role_policy.arn
}

##############################################################
# Attach the secrets policy to your ECS task execution role
##############################################################
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_secrets" {
    role = aws_iam_role.ecs_task_execution_role.name
    policy_arn = var.secrets_policy_arn
}

####################################################
# CloudWatch Log Group
####################################################
resource "aws_cloudwatch_log_group" "log" {
    retention_in_days = 14
}
