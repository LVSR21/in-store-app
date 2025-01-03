######################################################################
## Create IAM Role for EC2 Instances so that they can work with ECS ##
######################################################################

resource "aws_iam_role" "ec2_instance_role" {
  name               = "${var.namespace}_EC2_InstanceRole_${var.environment}"     # Name of the IAM Role
  assume_role_policy = data.aws_iam_policy_document.ec2_instance_role_policy.json # Policy document for the IAM Role - IAM role policies in AWS are always stored as JSON documents.

  tags = {
    Scenario = var.scenario
  }
}


####################################################################################
## Attach the policy to the EC2 Instances IAM Role so that they can work with ECS ##
####################################################################################

resource "aws_iam_role_policy_attachment" "ec2_instance_role_policy" {
  role       = aws_iam_role.ec2_instance_role.name                                        # Name of the IAM Role
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role" # ARN of the policy to attach - this specific ARN references the Amazon EC2 Container Service for EC2 Role Policy. This is a standard AWS managed policy required for WEC2 instances to work with ECS. This policy allows EC2 instances to register with ECS clusters, access container images, send logs to CloudWatch, interact with other AWS services needed for ECS operation and more.
}


######################################################################################
## Create IAM Instance Profile for EC2 Instances so that they can work with the ECS ##
######################################################################################

resource "aws_iam_instance_profile" "ec2_instance_role_profile" {
  name = "${var.namespace}_EC2_InstanceRoleProfile_${var.environment}"  # Name of the IAM Instance Profile
  role = aws_iam_role.ec2_instance_role.id                              # ID of the IAM Role to associate with the IAM Instance Profile

  tags = {
    Scenario = var.scenario
  }
}


###################################################################################
## Create a Trust Policy Document for ECS and EC2 so that they can work together ##
###################################################################################

data "aws_iam_policy_document" "ec2_instance_role_policy" {
  statement {                     # The statement block defines the permissions that the policy allows. In this case, the policy allows the IAM role to assume another role.
    actions = ["sts:AssumeRole"]  # The action that the policy allows. In this case, the action is "sts:AssumeRole", which allows the IAM role to assume another role.
    effect  = "Allow"             # The effect that the policy has. In this case, the effect is "Allow", which allows the action to be performed.

    principals {                  # The principals block defines the entities that are allowed to assume the role. In this case, the entity is an AWS service.
      type = "Service"            # The type of entity that is allowed to assume the role. In this case, the entity is a service.
      identifiers = [             # The identifiers of the entity that is allowed to assume the role. In this case, the identifiers are the ECS and EC2 services.
        "ec2.amazonaws.com",      # The identifier for the EC2 service.
        "ecs.amazonaws.com"       # The identifier for the ECS service.
      ]
    }
  }
}


###############################################################
## Create IAM Role for ECS Service to manage the ECS Cluster ##
###############################################################

resource "aws_iam_role" "ecs_service_role" {
  name               = "${var.namespace}_ECS_ServiceRole_${var.environment}"  # Name of the IAM Role
  assume_role_policy = data.aws_iam_policy_document.ecs_service_policy.json   # Policy document for the IAM Role - IAM role policies in AWS are always stored as JSON documents.

  tags = {
    Scenario = var.scenario
  }
}


########################################################################################
## Create a Trust Policy Document for ECS so that it can work with other AWS services ##
########################################################################################

data "aws_iam_policy_document" "ecs_service_policy" {
  statement {                    # The statement block defines the permissions that the policy allows. In this case, the policy allows the IAM role to assume another role.
    actions = ["sts:AssumeRole"] # The action that the policy allows. In this case, the action is "sts:AssumeRole", which allows the IAM role to assume another role.
    effect  = "Allow"            # The effect that the policy has. In this case, the effect is "Allow", which allows the action to be performed.

    principals {                            # The principals block defines the entities that are allowed to assume the role. In this case, the entity is an AWS service.
      type        = "Service"               # The type of entity that is allowed to assume the role. In this case, the entity is a service.
      identifiers = ["ecs.amazonaws.com", ] # The identifiers of the entity that is allowed to assume the role. In this case, the identifiers are the ECS service.
    }
  }
}


#######################################################################################
## Create IAM Role Policy for ECS Service Role so that it can manage the ECS Cluster ##
#######################################################################################

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "${var.namespace}_ECS_ServiceRolePolicy_${var.environment}"  # Name of the IAM Role Policy
  policy = data.aws_iam_policy_document.ecs_service_role_policy.json    # Policy document for the IAM Role Policy - IAM role policies in AWS are always stored as JSON documents.
  role   = aws_iam_role.ecs_service_role.id                             # ID of the IAM Role to attach the policy to
}


######################################################################################################################
## Create a Trust Policy Document for ECS Service Role to assume other roles so that it can manage the ECS Cluster ##
######################################################################################################################

data "aws_iam_policy_document" "ecs_service_role_policy" {
  statement {                                                     # The statement block defines the permissions that the policy allows. In this case, the policy allows the IAM role to assume another role.
    effect = "Allow"                                              # The effect that the policy has. In this case, the effect is "Allow", which allows the action to be performed.
    actions = [                                                   # The actions that the policy allows. In this case, the policy allows the IAM role to perform various actions related to ECS services.
      "ec2:AuthorizeSecurityGroupIngress",                        # The actions that the policy allows. In this case, the policy allows the IAM role to authorize security group ingress.
      "ec2:Describe*",                                            # The actions that the policy allows. In this case, the policy allows the IAM role to describe EC2 instances.
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer", # The actions that the policy allows. In this case, the policy allows the IAM role to deregister instances from a load balancer.
      "elasticloadbalancing:DeregisterTargets",                   # The actions that the policy allows. In this case, the policy allows the IAM role to deregister targets from a load balancer.
      "elasticloadbalancing:Describe*",                           # The actions that the policy allows. In this case, the policy allows the IAM role to describe Elastic Load Balancing resources.
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",   # The actions that the policy allows. In this case, the policy allows the IAM role to register instances with a load balancer.
      "elasticloadbalancing:RegisterTargets",                     # The actions that the policy allows. In this case, the policy allows the IAM role to register targets with a load balancer.
      "ec2:DescribeTags",                                         # The actions that the policy allows. In this case, the policy allows the IAM role to describe EC2 tags.
      "logs:CreateLogGroup",                                      # The actions that the policy allows. In this case, the policy allows the IAM role to create a log group.
      "logs:CreateLogStream",                                     # The actions that the policy allows. In this case, the policy allows the IAM role to create a log stream.
      "logs:DescribeLogStreams",                                  # The actions that the policy allows. In this case, the policy allows the IAM role to describe log streams.
      "logs:PutSubscriptionFilter",                               # The actions that the policy allows. In this case, the policy allows the IAM role to put a subscription filter on a log group.
      "logs:PutLogEvents"                                         # The actions that the policy allows. In this case, the policy allows the IAM role to put log events in a log stream.
    ]
    resources = ["*"]                                             # The resources that the policy allows the IAM role to access. In this case, the policy allows the IAM role to access all resources.
  }
}


###################################################################################
## Create IAM Role for ECS Task Execution so that ECS tasks can assume IAM roles ##
###################################################################################

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.namespace}_ECS_TaskExecutionRole_${var.environment}"  # Name of the IAM Role
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json    # Policy document for the IAM Role - IAM role policies in AWS are always stored as JSON documents.

  tags = {
    Scenario = var.scenario
  }
}


###########################################################################################
## Create a Trust Policy Document for ECS Task Execution so that it can assume IAM roles ##
###########################################################################################

data "aws_iam_policy_document" "task_assume_role_policy" {
  statement {                                   # The statement block defines the permissions that the policy allows. In this case, the policy allows the IAM role to assume another role.
    actions = ["sts:AssumeRole"]                # The action that the policy allows. In this case, the action is "sts:AssumeRole", which allows the IAM role to assume another role.

    principals {                                # The principals block defines the entities that are allowed to assume the role. In this case, the entity is an AWS service.
      type        = "Service"                   # The type of entity that is allowed to assume the role. In this case, the entity is a service.
      identifiers = ["ecs-tasks.amazonaws.com"] # The identifiers of the entity that is allowed to assume the role. In this case, the identifiers are the ECS service.
    }
  }
}


#############################################################################################
## Attach the policy to the ECS Task Execution Role so that ECS tasks can assume IAM roles ##
#############################################################################################

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name                               # Name of the IAM Role
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy" # ARN of the policy to attach - this specific ARN references the Amazon ECS Task Execution Role Policy. This is a standard AWS managed policy required for ECS tasks to work with IAM roles. This policy allows ECS tasks to assume IAM roles, access container images, send logs to CloudWatch, interact with other AWS services needed for ECS operation and more.
}


########################################################
## Create IAM Role for ECS Tasks so that they can run ##
########################################################

resource "aws_iam_role" "ecs_task_iam_role" {
  name               = "${var.namespace}_ECS_TaskIAMRole_${var.environment}"      # Name of the IAM Role
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json  # Policy document for the IAM Role - IAM role policies in AWS are always stored as JSON documents.

  tags = {
    Scenario = var.scenario
  }
}



#------------------------- EXPLANATION -------------------------#
# IAM (Identity and Access Management) roles are used to define the permissions and policies that are associated with AWS resources.
# IAM us a core AWS security service that controls authentication and authorization.
# IAM manages who can access what in my AWS environment.
# In this Terraform configuration, I create IAM roles for EC2 instances, ECS services, ECS task execution, and ECS tasks to enable them to work with the ECS (Elastic Container Service) cluster. 
# The IAM roles are created using the 'aws_iam_role' resource type, and the policies are attached to the roles using the 'aws_iam_role_policy_attachment' resource type. 
# The policies define the permissions that the roles have, such as the ability to assume other roles, access container images, send logs to CloudWatch, interact with other AWS services, and more. 
# The IAM roles are essential for the proper functioning of the ECS cluster and its associated resources.