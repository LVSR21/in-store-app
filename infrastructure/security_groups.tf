############################################
## Create Security Group for Bastion Host ##
############################################

resource "aws_security_group" "bastion_host" {
  name        = "${var.namespace}_SecurityGroup_BastionHost_${var.environment}" # The name of the Security Group
  description = "Bastion host Security Group"                                   # The description of the Security Group
  vpc_id      = aws_vpc.default.id                                              # The VPC ID where the Security Group will be created

  ingress {                                                                     # Ingress rules configurations:
    description = "Allow SSH"                                                   # The description of the rule
    from_port   = 22                                                            # The port from which the traffic is allowed
    to_port     = 22                                                            # The port to which the traffic is allowed
    protocol    = "tcp"                                                         # The protocol of the traffic - TCP (Transmission Control Protocol) in this case ensures that the connection is reliable and ensure that all SSH packets arrive correctly and in order, maintaining stable remote access sessions.
    cidr_blocks = ["20.223.228.255/32"]                                         # The CIDR block allows inbound traffic to connect to the bastion host - in this case is the Server Public IP of my OpenVPN
  }

  egress {                                                                      # Egress rules configurations:
    description = "Allow all outbound traffic"                                  # The description of the rule
    from_port   = 0                                                             # The port from which the traffic is allowed - in this case from all ports
    to_port     = 0                                                             # The port to which the traffic is allowed - in this case to all ports
    protocol    = -1                                                            # The protocol of the traffic - '-1' means all protocols
    cidr_blocks = ["0.0.0.0/0"]                                                 # The CIDR block that allows all outbound traffic
  }

  tags = {
    Scenario = var.scenario
  }
}


#############################################
## Create Security Group for EC2 Instances ##
#############################################

resource "aws_security_group" "ec2" {
  name        = "${var.namespace}_EC2_Instance_SecurityGroup_${var.environment}"  # The name of the Security Group
  description = "Security group for EC2 instances in ECS cluster"                 # The description of the Security Group
  vpc_id      = aws_vpc.default.id                                                # The VPC ID where the Security Group will be created

  ingress {                                                                       # Ingress rules configurations:
    description     = "Allow ingress traffic from ALB on HTTP on ephemeral ports" # The description of the rule
    from_port       = 1024                                                        # The port from which the traffic is allowed (ephemeral ports)
    to_port         = 65535                                                       # The port to which the traffic is allowed (ephemeral ports)
    protocol        = "tcp"                                                       # The protocol of the traffic - TCP (Transmission Control Protocol) in this case ensures that the connection is reliable between the ALB and EC2 instances running in the ECS cluster.
    security_groups = [aws_security_group.alb.id]                                 # The Security Group ID of the ALB
  }

  ingress {                                                                       # Ingress rules configurations:
    description     = "Allow SSH ingress traffic from bastion host"               # The description of the rule
    from_port       = 22                                                          # The port from which the traffic is allowed (SSH)
    to_port         = 22                                                          # The port to which the traffic is allowed (SSH)
    protocol        = "tcp"                                                       # The protocol of the traffic - TCP (Transmission Control Protocol) in this case ensures that the connection is reliable and ensure that all SSH packets arrive correctly and in order, maintaining stable remote access sessions.
    security_groups = [aws_security_group.bastion_host.id]                        # The Security Group ID of the bastion host
  }

  egress {                                                                        # Egress rules configurations:
    description = "Allow all egress traffic"                                      # The description of the rule
    from_port   = 0                                                               # The port from which the traffic is allowed - in this case from all ports
    to_port     = 0                                                               # The port to which the traffic is allowed - in this case to all ports
    protocol    = -1                                                              # The protocol of the traffic - '-1' means all protocols
    cidr_blocks = ["0.0.0.0/0"]                                                   # The CIDR block that allows all outbound traffic
  }

  tags = {
    Name     = "${var.namespace}_EC2_Instance_SecurityGroup_${var.environment}"
    Scenario = var.scenario
  }
}


###############################################################
## Create Security Group for Application Load Balancer (ALB) ##
###############################################################

resource "aws_security_group" "alb" {
  name        = "${var.namespace}_ALB_SecurityGroup_${var.environment}" # The name of the Security Group
  description = "Security group for ALB"                                # The description of the Security Group
  vpc_id      = aws_vpc.default.id                                      # The VPC ID where the Security Group will be created

  egress {                                                              # Egress rules configurations:
    description = "Allow all egress traffic"                            # The description of the rule
    from_port   = 0                                                     # The port from which the traffic is allowed - in this case from all ports
    to_port     = 0                                                     # The port to which the traffic is allowed - in this case to all ports
    protocol    = -1                                                    # The protocol of the traffic - '-1' means all protocols
    cidr_blocks = ["0.0.0.0/0"]                                         # The CIDR block that allows all outbound traffic
  }

  tags = {
    Name     = "${var.namespace}_ALB_SecurityGroup_${var.environment}"
    Scenario = var.scenario
  }
}


###############################################################################
## Get the CloudFront CIDR blocks to allow HTTPS access only from CloudFront ##
###############################################################################

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing" # The name of the prefix list -  this is the prefix list that contains the CloudFront CIDR blocks
}


#############################################################################################################
## Create Security Group Rule for ALB to allow incoming traffic on HTTPS from known CloudFront CIDR blocks ##
#############################################################################################################

resource "aws_security_group_rule" "alb_cloudfront_https_ingress_only" {
  security_group_id = aws_security_group.alb.id                             # The Security Group ID of the ALB
  description       = "Allow HTTPS access only from CloudFront CIDR blocks" # The description of the rule
  from_port         = 443                                                   # The port from which the traffic is allowed (HTTPS)
  protocol          = "tcp"                                                 # The protocol of the traffic - TCP (Transmission Control Protocol) in this case ensures that the connection is reliable and secure between the ALB and CloudFront
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront.id]      # The prefix list ID that contains the CloudFront CIDR blocks
  to_port           = 443                                                   # The port to which the traffic is allowed (HTTPS)
  type              = "ingress"                                             # The type of the rule - ingress in this case allows incoming traffic
}



#------------------------- EXPLANATION -------------------------#
# Security Groups are virtual firewalls for AWS resources that control inbound and outbound traffic.
# They acts as the first line of defense at the instance/resource level.
# In this Terraform configuration, we create three Security Groups: Bastion Host, ECS Instances, and ALB.