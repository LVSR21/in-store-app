##########################################
## Create IAM policy for Secrets access ##
##########################################

resource "aws_iam_policy" "secrets_policy" {
  name = "ecs-secrets-policy"                                                                       # Name of the policy
  policy = jsonencode({                                                                             # Policy document - this is a JSON object
    Version = "2012-10-17"                                                                          # Version of the policy language
    Statement = [                                                                                   # List of statements (statements are the permissions):
      {
        Effect = "Allow"                                                                            # The effect of the statement - Allow
        Action = [                                                                                  # List of actions that are allowed:
          "secretsmanager:GetSecretValue"                                                           # Get secret value action -  this is the action that I want to allow
        ]
        Resource = [                                                                                # List of resources that the action is allowed on:
          "arn:aws:secretsmanager:eu-west-2:344615752961:secret:jd-mongodb-connection-string-prod-*" # ARN of the secret - this is the secret that I want to access
        ]
      }
    ]
  })
}

##############################################
## Attach policy to ECS task execution role ##
##############################################

resource "aws_iam_role_policy_attachment" "secrets_policy_attachment" {
  role       = "jd_ECS_TaskExecutionRole_prod"     # The role that the policy will be attached to - this is the ECS task execution role created under the 'ecs_iam.tf' file
  policy_arn = aws_iam_policy.secrets_policy.arn  # The ARN of the policy that will be attached
}



#------------------------- EXPLANATION -------------------------#
# IAM (Identity and Access Management) roles are used to define the permissions and policies that are associated with AWS resources.
# IAM us a core AWS security service that controls authentication and authorization.
# IAM manages who can access what in my AWS environment.
# In this Terraform configuration, I am creating an IAM policy that allows my ECS task to access a secret stored in AWS Secrets Manager (my MongoDB connection string).