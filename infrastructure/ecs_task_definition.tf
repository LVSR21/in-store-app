####################################################
## Create ECS Task Definition for the ECS Service ##
####################################################

resource "aws_ecs_task_definition" "default" {
  family             = "${var.namespace}_ECS_TaskDefinition_${var.environment}"           # My ECS Task Definition name
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn                           # The ARN of the IAM role that allows Amazon ECS to pull the container image from Amazon ECR
  task_role_arn      = aws_iam_role.ecs_task_iam_role.arn                                 # The ARN of the IAM role that allows Amazon ECS to make AWS API calls on my behalf
  memory             = 2048                                                               # 2 GiB for the ECS Task Definition
  cpu                = 1024                                                               # 1 vCPU for the ECS Task Definition

  container_definitions = jsonencode([                                                    # The container definitions as a JSON string - I use the 'jsonencode' function to convert the list of container definitions to a JSON string
    {
      name      = "nginx"                                                                 # Name of the container
      image     = "${data.aws_ecr_repository.ecr_repo.repository_url}:in-store-app-nginx" # My nginx image
      cpu       = 256                                                                     # 0.25 vCPU for nginx
      memory    = 1024                                                                    # 1 GiB for nginx
      essential = true                                                                    # The container is essential - this means that if the container fails, the ECS Task will stop
      portMappings = [                                                                    # The port mappings configuration for the nginx container:
        {
          containerPort = 80                                                              # The port on the container
          hostPort      = 0                                                               # Dynamically assign a port - this is useful when running multiple tasks on the same container instance as it avoids port conflicts
          protocol      = "tcp"                                                           # The protocol used for the port mapping - TCP (Transmission Control Protocol) is essential for my nginx container since it's serving web traffic and needs reliable data transmission (HTTP web traffic). TCP ensures data arrives complete and in order, it handles retransmission of lost packets, provides error checking and guarantees reliable ordered delivery of data.
        }
      ]
      links = ["client", "api"]                                                           # Links to other containers - client and api
      logConfiguration = {                                                                # The log configuration for the container:
        logDriver = "awslogs",                                                            # The log driver to use - in this case AWS CloudWatch Logs
        options = {                                                                       # The options configuration for the log driver:
          "awslogs-group"         = aws_cloudwatch_log_group.log_group.name,              # The name of the CloudWatch log group -  this means that the log group will be created with the name of the ECS Task Definition
          "awslogs-region"        = var.region,                                           # The region of the CloudWatch log group -  this means that the log group will be created in the same region as the ECS Task Definition
          "awslogs-stream-prefix" = "nginx"                                               # The prefix for the CloudWatch log stream -  this means that the log stream name will be 'nginx' followed by a unique identifier
        }
      }
    },
    {
      name      = "client"                                                                  # Name of the container
      image     = "${data.aws_ecr_repository.ecr_repo.repository_url}:in-store-app-client"  # My client image
      cpu       = var.cpu_units                                                             # The CPU units for the client container
      memory    = var.memory                                                                # The memory for the client container
      essential = true                                                                      # The container is essential - this means that if the container fails, the ECS Task will stop
      portMappings = [                                                                      # The port mappings configuration for the client container:
        {
          containerPort = 3000                                                              # The port on the container - this one matches my Nginx upstream configuration
          protocol      = "tcp"                                                             # The protocol used for the port mapping - TCP (Transmission Control Protocol) is essential for my client container since it's serving web traffic and needs reliable data transmission (HTTP web traffic). TCP ensures data arrives complete and in order, it handles retransmission of lost packets, provides error checking and guarantees reliable ordered delivery of data.
        }
      ]
      logConfiguration = {                                                                  # The log configuration for the container:
        logDriver = "awslogs",                                                              # The log driver to use - in this case AWS CloudWatch Logs
        options = {                                                                         # The options configuration for the log driver:
          "awslogs-group"         = aws_cloudwatch_log_group.log_group.name,                # The name of the CloudWatch log group -  this means that the log group will be created with the name of the ECS Task Definition
          "awslogs-region"        = var.region,                                             # The region of the CloudWatch log group -  this means that the log group will be created in the same region as the ECS Task Definition
          "awslogs-stream-prefix" = "client"                                                # The prefix for the CloudWatch log stream -  this means that the log stream name will be 'client' followed by a unique identifier
        }
      }
    },
    {
      name      = "api"                                                                 # Name of the container
      image     = "${data.aws_ecr_repository.ecr_repo.repository_url}:in-store-app-api" # My api image
      cpu       = var.cpu_units                                                         # The CPU units for the api container
      memory    = var.memory                                                            # The memory for the api container
      essential = true                                                                  # The container is essential - this means that if the container fails, the ECS Task will stop
      portMappings = [                                                                  # The port mappings configuration for the api container:
        {
          containerPort = 5000                                                          # The port on the container - this one matches my Nginx upstream configuration
          protocol      = "tcp"                                                         # The protocol used for the port mapping - TCP (Transmission Control Protocol) is essential for my api container since it's serving web traffic and needs reliable data transmission (HTTP web traffic). TCP ensures data arrives complete and in order, it handles retransmission of lost packets, provides error checking and guarantees reliable ordered delivery of data.
        }
      ]
      environment = [                                                                   # The environment variables for the api container:
        {
          name  = "NODE_ENV"                                                            # The name of the environment variable
          value = "production"                                                          # The value of the environment variable - in this case is set to 'production' to run Node.js in production mode.
        },
        {
          name  = "PORT"                                                                # The name of the environment variable
          value = "5000"                                                                # The value of the environment variable - in this case is set to '5000' to run the API on port 5000.
        }
      ]
      secrets = [                                                                       # The secrets configuration for the api container:
        {
          name      = "mongodb_connection_string"                                       # The name of the secret
          valueFrom = aws_secretsmanager_secret.mongodb.arn                             # The ARN of the secret - in this case, the ARN of the MongoDB connection string stored in AWS Secrets Manager. In here I use the 'arn' of the secret because ECS retrieve the secret value at runtime. The ARN is used to reference the secret in AWS Secrets Manager and ECS handles fetching the actual secret value securely.
        }
      ]
      logConfiguration = {                                                              # The log configuration for the container:
        logDriver = "awslogs",                                                          # The log driver to use - in this case AWS CloudWatch Logs
        options = {                                                                     # The options configuration for the log driver:
          "awslogs-group"         = aws_cloudwatch_log_group.log_group.name,            # The name of the CloudWatch log group -  this means that the log group will be created with the name of the ECS Task Definition
          "awslogs-region"        = var.region,                                         # The region of the CloudWatch log group -  this means that the log group will be created in the same region as the ECS Task Definition
          "awslogs-stream-prefix" = "api"                                               # The prefix for the CloudWatch log stream -  this means that the log stream name will be 'api' followed by a unique identifier
        }
      }
    }
  ])

  tags = {
    Scenario = var.scenario
  }
}



#------------------------- EXPLANATION -------------------------#
# ECS Task Definition is like a blueprint that describes how Docker containers should run in AWS ECS.
# It specifies important details such as which Docker images to use, how much CPU and memory to allocate, environment variables, networking configuration, logging settings, and more.