####################################################
# 
####################################################
data "aws_ecr_repository" "in_store_app_repo" {
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
# ECS Task Definition
####################################################
resource "aws_ecs_task_definition" "ecs_task_definition" {
    family             = "in-store-app-task"
    network_mode       = "bridge" # Use bridge for EC2 launch type
    execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn # CHANGE THIS LINE ONCE IAM ROLE IS DEFINED BELOW!!!

    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture        = "X86_64"
    }

    container_definitions = jsonencode([
    {
        name      = "nginx"
        image     = "${var.ecr_repository_url}/nginx:latest" # My Nginx image
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
        logConfiguration = {
            logDriver = "awslogs"
            options = {
                "awslogs-group"         = aws_cloudwatch_log_group.log.name # CHANGE THIS LINE ONCE CLOUDWATCH LOG GROUP IS DEFINED BELOW!!!
                "awslogs-region"        = var.aws_region
                "awslogs-stream-prefix" = "nginx"
            }
        }
    },
    {
        name      = "client"
        image     = "${var.ecr_repository_url}/client:latest" # My Client image
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
                "awslogs-group"         = aws_cloudwatch_log_group.log.name # CHANGE THIS LINE ONCE CLOUDWATCH LOG GROUP IS DEFINED BELOW!!!
                "awslogs-region"        = var.aws_region
                "awslogs-stream-prefix" = "client"
            }
        }
    },
    {
        name      = "api" # From Docker-Compose file
        image     = "${var.ecr_repository_url}/api:latest" # My Server image
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
                valueFrom = aws_secretsmanager_secret_mongodb.uri.arn # CHANGE THIS ACCORDING TO MY SECRET MANAGER SECRET ARN
            }
        ]
        logConfiguration = {
            logDriver = "awslogs"
            options = {
                "awslogs-group"         = aws_cloudwatch_log_group.log.name # CHANGE THIS LINE ONCE CLOUDWATCH LOG GROUP IS DEFINED BELOW!!!
                "awslogs-region"        = var.aws_region
                "awslogs-stream-prefix" = "api"
            }
        }
    }
    ])
}



####################################################
# Create an IAM role - ecsTaskExecutionRole  
####################################################





####################################################
# Create cloudWatch Log Group
####################################################



####################################################
# Create Secrets Manager Secret
####################################################