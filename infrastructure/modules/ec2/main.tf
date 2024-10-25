##########################################################
# Get latest Amazon Linux 2 AMI for ECS EC2 Instances
##########################################################
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

##########################################################
# Launch Template Resource for ECS EC2 Instances
##########################################################
resource "aws_launch_template" "ec2_launch_template" {
  image_id               = data.aws_ami.amazon_linux_2.id
  instance_type          = var.ec2_instance_type
  key_name               = var.instance_key_pair
  user_data              = filebase64("${path.module}/ecs.sh")
  vpc_security_group_ids = [var.ec2_security_group_id]
  update_default_version = true

  private_dns_name_options {
    enable_resource_name_dns_a_record = false
  }

  iam_instance_profile {
    name = aws_iam_role.ecsInstanceRole.name
  }

  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp2"
    }
  }

  tags = {
    "Name" = "${var.project_name}-ecs-ec2"
  }
}

################################################################
# Fetch Predefined IAM Policy for ECS Instance Role
################################################################
data "aws_iam_policy" "ecs_instance_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role" # This is prefefined policy for ECS - please see IAM policies for more details.
}


#################################################################
# IAM Policy Document for EC2 Instances to Assume Roles in ECS 
#################################################################
data "aws_iam_policy_document" "ecs_instance_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

#################################################################
# IAM Role for ECS EC2 Instances
#################################################################
resource "aws_iam_role" "ecs_instance_role" {
  name               = "ecsInstanceRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_instance_role_policy.json
}

#################################################################
# Attach IAM Policy to ECS EC2 Instances Role
#################################################################
resource "aws_iam_role_policy_attachment" "ecs_instance_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = data.aws_iam_policy.ecs_instance_role_policy.arn
}

#################################################################
# IAM Instance Profile for ECS EC2 Instances
#################################################################
resource "aws_iam_instance_profile" "ecs_instance_role_profile" {
  name = aws_iam_role.ecs_instance_role.name
  role = aws_iam_role.ecs_instance_role.name
}