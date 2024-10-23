##########################################################
# Get latest Amazon Linux 2 AMI for ECS EC2 Instances
##########################################################
data "aws_ami" "amazon-linux-2" {
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
resource "aws_launch_template" "ec2-launch-template" {
  image_id               = data.aws_ami.amazon-linux-2.id
  instance_type          = var.ec2_instance_type
  key_name               = var.instance_key_pair
  user_data              = filebase64("${path.module}/ecs.sh")
  vpc_security_group_ids = [var.ec2_security_group_id]
  update_default_version = true

  private_dns_name_options {
    enable_resource_name_dns_a_record = false
  }

  iam_instance_profile {
    name = aws_iam_role.ecsInstanceRole.name # ATTENTION: replace with output from IAM module
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
