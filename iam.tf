resource "aws_iam_role" "tfc_agent_role" {
  name = "tfc_agent_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "tfc_agent_profile" {
  name = "tfc_agent_profile"
  role = aws_iam_role.tfc_agent_role.name
}

resource "aws_iam_role_policy" "tfc_agent_policy" {
  role = aws_iam_role.tfc_agent_role.name
  name = "${var.cluster_name}-tfc-agent"

  policy = <<__policy
{
    "Version": "2012-10-17",
    "Statement": [{
        "Resource": [
            "*"
        ],
        "Effect": "Allow",
        "Action": [
            "s3:*",
            "ec2:*",
            "elasticloadbalancing:*",
            "cloudwatch:*",
            "autoscaling:*"
        ]
    }]
}
__policy
}