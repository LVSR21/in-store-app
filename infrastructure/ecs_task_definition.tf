########################################################################################################################
## Creates ECS Task Definition
########################################################################################################################

resource "aws_ecs_task_definition" "default" {
  family             = "${var.namespace}_ECS_TaskDefinition_${var.environment}"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_iam_role.arn
  memory             = 2048
  cpu                = 1024
  # network_mode       = "bridge" # Default for EC2 ECS

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "${data.aws_ecr_repository.ecr_repo.repository_url}:nginx" # My nginx image
      cpu       = 256                                                        # 0.25 vCPU
      memory    = 1024                                                       # 1 GiB for nginx
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
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.log_group.name,
          "awslogs-region"        = var.region,
          "awslogs-stream-prefix" = "nginx"
        }
      }
    },
    {
      name      = "client"
      image     = "${data.aws_ecr_repository.ecr_repo.repository_url}:client" # My client image
      cpu       = var.cpu_units
      memory    = var.memory
      essential = true
      portMappings = [
        {
          containerPort = 3000 # Matches my Nginx upstream configuration
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "WDS_SOCKET_PORT" # From my Docker-Compose
          value = "0"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.log_group.name,
          "awslogs-region"        = var.region,
          "awslogs-stream-prefix" = "client"
        }
      }
    },
    {
      name      = "api"                                                    # From Docker-Compose file
      image     = "${data.aws_ecr_repository.ecr_repo.repository_url}:api" # My api image
      cpu       = var.cpu_units
      memory    = var.memory
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
          valueFrom = aws_secretsmanager_secret.mongodb.arn # In here I use the 'arn' of the secret because ECS retrieve the secret value at runtime. The ARN is used to reference the secret in AWS Secrets Manager and ECS handles fetching the actual secret value securely.
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.log_group.name,
          "awslogs-region"        = var.region,
          "awslogs-stream-prefix" = "api"
        }
      }
    }
  ])

  tags = {
    Scenario = var.scenario
  }
}