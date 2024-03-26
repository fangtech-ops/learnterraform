resource "aws_security_group" "notification_preferences" {
  name        = "notification_preferences-${local.vpc_name}"
  description = "Notification Preferences Security Group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "notification_preferences-${local.vpc_name}"
  }
}

resource "aws_iam_role" "notification_preferences" {
  name               = "app-notification_preferences-${local.vpc_shortname}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_policy" "notification_preferences_policy" {
  name   = "notification_preferences_policy-${local.vpc_shortname}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "cloudwatch:*",
            "logs:*",
            "apigateway:*",
            "ec2:CreateNetworkInterface",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeNetworkInterfaces"

        ],
        "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "notification_preferences_attachment" {
  role       = aws_iam_role.notification_preferences.name
  policy_arn = aws_iam_policy.notification_preferences_policy.id
}

