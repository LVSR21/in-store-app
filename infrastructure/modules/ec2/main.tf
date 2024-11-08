############################################################################################################
# Get most recent AMI for an ECS-optimized Amazon Linux 2 instance
# -------------------------------------------------------------------
# Must select appropriate AMI to use and ECS-optimized image on which the ECS Agent is installed.
############################################################################################################
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"] # This specifies that I want AMIs owned by Amazon.

  filter {
    name   = "virtualization-type"
    values = ["hvm"] # This specifies that only AMIs with HVM virtualization will be selected.
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"] # This restricts the search to AMIs owned by Amazon.
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"] # This filters by AMI names that match the specified pattern.
  }
}

############################################################################
# Launch template for all EC2 instances that are part of the ECS cluster
############################################################################
resource "aws_launch_template" "ec2_launch_template" {
  name                   = "${var.project_name}-${var.environment}-ec2-launch-template"
  image_id               = data.aws_ami.amazon_linux_2.id
  instance_type          = var.ec2_instance_type
  key_name               = var.instance_key_pair
  user_data              = filebase64("${path.module}/ecs.sh") # In order to use the EC2 instances as part of the ECS Cluster after startup, I need to configure the cluster name. To do this the name is written to the ECS config file /etc/ecs/ecs.config. This is done in the ecs.sh file that is executed when the EC2 instance is started.
  vpc_security_group_ids = [var.ec2_security_group_id]

  iam_instance_profile {
    name = aws_iam_role.ec2_instance_role.name
  }

  monitoring {
    enabled = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-launch-template"
  }
}

#################################################################
# IAM Role for EC2 Instances
#################################################################
resource "aws_iam_role" "ec2_instance_role" {
  name               = "${var.project_name}-${var.environment}-ec2-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_instance_role_policy.json
}

#################################################################
# Attach IAM Policy for EC2 Instances Role
#################################################################
resource "aws_iam_role_policy_attachment" "ec2_instance_role_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role" # This is prefefined policy for ECS - please see IAM policies for more details.
}

#################################################################################################
# Attach CloudFront Secret IAM Policy to EC2 Role
# -------------------------------------------------
# This policy allows the EC2 instances to read the CloudFront secret from AWS Secrets Manager.
#################################################################################################
resource "aws_iam_role_policy_attachment" "ec2_secret_policy_attachment" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = var.cloudfront_secrets_policy_arn
}

#################################################################
# IAM Instance Profile for EC2 Instances
#################################################################
resource "aws_iam_instance_profile" "ecs_instance_role_profile" {
  name = "${var.project_name}-${var.environment}-ec2-instance-role-profile"
  role = aws_iam_role.ec2_instance_role.id
}

#######################################################################
# Fetch IAM Policy Document for EC2 Instances to Assume Roles in ECS 
#######################################################################
data "aws_iam_policy_document" "ec2_instance_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = [
        "ec2.amazonaws.com",
        "ecs.amazonaws.com"
      ]
    }
  }
}