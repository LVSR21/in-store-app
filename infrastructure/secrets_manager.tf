###########################
## Create MongoDB secret ##
###########################

resource "aws_secretsmanager_secret" "mongodb" {
  name        = "${var.namespace}-mongodb-connection-string-${var.environment}" # Name of the secret
  description = "MongoDB connection string for the api container."              # Description of the secret

  tags = {
    Name = "${var.namespace}_mongodb-connection-string_${var.environment}"
  }
}


#########################################
## Create MongoDB secret value version ##
#########################################

resource "aws_secretsmanager_secret_version" "mongodb" {
  secret_id     = aws_secretsmanager_secret.mongodb.id  # ID of the secret
  secret_string = var.mongodb_connection_string         # Value of the secret
}


##########################################################
## Data source to read the MongoDB secret value version ##
##########################################################

data "aws_secretsmanager_secret_version" "mongodb" {
  secret_id  = aws_secretsmanager_secret.mongodb.id         # ID of the secret
  depends_on = [aws_secretsmanager_secret_version.mongodb]  # Depends on the secret value version
}


###########################################################
## Create IAM policy to allow ECS to read MongoDB secret ##
###########################################################

resource "aws_iam_policy" "mongodb_secrets_policy" {
  name        = "mongodb-secrets-policy"                                                # Name of the policy
  description = "IAM policy to allow ECS to read MongoDB secret from Secrets Manager."  # Description of the policy

  policy = jsonencode({                                                                 # Policy document - this a JSON object
    Version = "2012-10-17",                                                             # Version of the policy language
    Statement = [                                                                       # List of statements (statements are the permissions):
      {
        Effect = "Allow",                                                               # Effect of the statement - Allow
        Action = [                                                                      # List of actions:
          "secretsmanager:GetSecretValue",                                              # Action to get the secret value
          "secretsmanager:DescribeSecret"                                               # Action to describe the secret
        ],
        Resource = [                                                                    # List of resources:
          aws_secretsmanager_secret.mongodb.arn                                         # ARN of the secret - in this case the MongoDB secret
        ]
      }
    ]
  })
}


##############################
## Create CloudFront secret ##
##############################

resource "aws_secretsmanager_secret" "cloudfront" {
  name        = "${var.namespace}-cloudfront-origin-secret-${var.environment}"  # Name of the secret
  description = "CloudFront origin secret for ALB."                             # Description of the secret

  tags = {
    Name = "${var.namespace}_cloudfront-origin-secret_${var.environment}"
  }
}

############################################
## Create CloudFront secret value version ##
############################################

resource "aws_secretsmanager_secret_version" "cloudfront" {
  secret_id     = aws_secretsmanager_secret.cloudfront.id   # ID of the secret in this case the CloudFront secret
  secret_string = var.custom_origin_host_header             # Value of the secret in this case the custom origin host header
}


#############################################################
## Data source to read the CloudFront secret value version ##
#############################################################

data "aws_secretsmanager_secret_version" "cloudfront" {
  secret_id = aws_secretsmanager_secret.cloudfront.id           # ID of the secret
  depends_on = [aws_secretsmanager_secret_version.cloudfront]   # Depends on the secret value version
}


##########################################################################
## Create IAM policy for EC2 behind ALB access CloudFront origin secret ##
##########################################################################

resource "aws_iam_policy" "cloudfront_secrets_policy" {
  name        = "cloudfront-secrets-policy"                                           # Name of the policy
  description = "IAM policy to access CloudFront origin secret from Secrets Manager." # Description of the policy

  policy = jsonencode({                                                               # Policy document - this a JSON object
    Version = "2012-10-17",                                                           # Version of the policy language
    Statement = [                                                                     # List of statements (statements are the permissions):
      {
        Effect = "Allow",                                                             # Effect of the statement - Allow
        Action = [                                                                    # List of actions:
          "secretsmanager:GetSecretValue",                                            # Action to get the secret value
          "secretsmanager:DescribeSecret"                                             # Action to describe the secret
        ],
        Resource = [                                                                  # List of resources:
          aws_secretsmanager_secret.cloudfront.arn                                    # ARN of the secret - in this case the CloudFront secret
        ]
      }
    ]
  })
}



#------------------------- EXPLANATION -------------------------#
# AWS Secrets Manager is a service that helps to protect access to applications, services and IT resources by securely storing and managing sensitive information.
# AWS Secrets Manager encrypts at rest using KMS (Key Management Service), centralises secret management and provides fine-grained IAM access control.
# In my case I am using AWS Secrets Manager to store the MongoDB connection string and the CloudFront origin secret.