######################################################################
## Get most recent AMI for an ECS-optimized Amazon Linux 2 instance ##
######################################################################

data "aws_ami" "amazon_linux_2" {
  most_recent = true                # Get the most recent AMI

  filter {                          # Filter the AMI based on the following criteria:
    name   = "virtualization-type"  # Filter based on the virtualization type
    values = ["hvm"]                # Filter based on the hardware virtual machine (HVM) virtualization type
  }

  filter {                          # Filter the AMI based on the following criteria:
    name   = "owner-alias"          # Filter based on the owner alias
    values = ["amazon"]             # Filter based on the owner alias being 'amazon'
  }

  filter {                                      # Filter the AMI based on the following criteria:
    name   = "name"                             # Filter based on the name
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"] # Filter based on the name of the AMI
  }

  owners = ["amazon"]                           # Filter based on the owner of the AMI - in this case, the owner is 'amazon'
}


###################################################################################
## Create Launch template for all EC2 instances that are part of the ECS cluster ##
###################################################################################

resource "aws_launch_template" "ecs_launch_template" {
  name                   = "${var.namespace}_EC2_LaunchTemplate_${var.environment}" # Name of the launch template
  image_id               = data.aws_ami.amazon_linux_2.id                           # ID of the AMI to use for the instance
  instance_type          = var.instance_type                                        # Type of instance to launch
  key_name               = var.instance_key_pair                                    # Name of the key pair to use for the instance
  user_data              = base64encode(data.template_file.user_data.rendered)      # The user data to provide when launching the instance - this contains the script to update/upgrade the system packages and to install ClamAV, Nmap, Cronie and Curl..
  vpc_security_group_ids = [aws_security_group.ec2.id]                              # A list of security group IDs to associate with the ECS2 instances

  iam_instance_profile {                                          # The IAM instance profile to associate with launched instances
    arn = aws_iam_instance_profile.ec2_instance_role_profile.arn  # The ARN of the instance profile
  }

  monitoring {      # The monitoring configuration for the instances
    enabled = true  # Enable detailed monitoring
  }

  tags = {
    Name        = "ecs-instance-${var.environment}"
    Scenario    = var.scenario
    Environment = var.environment
    Role        = "ecs-instance"
  }
}


###########################
## Get user data file ##
###########################

data "template_file" "user_data" {
  template = file("user_data.sh")                                             # The file that contains the user data script

  vars = {                                                                    # Variables to pass to the user data file
    ecs_cluster_name           = aws_ecs_cluster.default.name                 # The name of the ECS cluster
    private_subnet_cidr_blocks = join(" ", aws_subnet.private[*].cidr_block)  # The CIDR blocks of the private subnets - please note that I need this variable to pass it to my 'user_data.sh' script file - this will contain the list of private subnet CIDR blocks needed for the Nmap scan.
  }
}



#------------------------- EXPLANATION -------------------------#
# ECS Instances Launch Template is like a blueprint for EC2 instances. It stores configuration details for launching instances, including AMI, instance type, security groups and user data.
# Launch Templates help maintain consistency across multiple instances.
# In my case Launch Template ensures all cluster instances have the correct ECS agent installed, proper IAM roles, required security groups and necessary monitoring settings.
# Launch Templates help to standardise across cluster instances, allowing for easier scaling an instance replacement, version control for instances configurations, reduce configuration errors and more.
# This Launch Template configuration sets up EC2 instances optimised for running ECS containers.