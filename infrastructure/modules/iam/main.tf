####################################################
# Create an IAM role - ecsInstanceRole  
####################################################
data "aws_iam_policy" "ecsInstanceRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

data "aws_iam_policy_document" "ecsInstanceRolePolicy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecsInstanceRole" {
  name               = "ecsInstanceRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecsInstanceRolePolicy.json
}

resource "aws_iam_role_policy_attachment" "ecsInstancePolicy" {
  role       = aws_iam_role.ecsInstanceRole.name
  policy_arn = data.aws_iam_policy.ecsInstanceRolePolicy.arn
}

resource "aws_iam_instance_profile" "ecsInstanceRoleProfile" {
  name = aws_iam_role.ecsInstanceRole.name
  role = aws_iam_role.ecsInstanceRole.name
}