resource "aws_s3_bucket" "application_logs" {
  bucket = "application-logs-${local.vpc_shortname}"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name  = "application-logs-${local.vpc_shortname}"
    stack = local.vpc_shortname
    sku   = "shared-services"
  }
}

resource "aws_kinesis_stream" "application_logs_stream" {
  name             = "application_logs_stream-${local.vpc_shortname}"
  shard_count      = 1
  retention_period = 24
  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]
  tags = {
    Name  = "application_logs_stream-${local.vpc_shortname}"
    stack = local.vpc_shortname
    sku   = "shared-services"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "application_logs_firehose" {
  name = "application_logs_firehose-${local.vpc_shortname}"

  # destination = "s3" # This line is deprecated: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream#s3-destination-deprecated
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.application_logs_stream.arn
    role_arn           = aws_iam_role.application_logs-role.arn
  }

  # s3_configuration { # This line is deprecated: as per above
  extended_s3_configuration {
    role_arn   = aws_iam_role.application_logs-role.arn
    bucket_arn = aws_s3_bucket.application_logs.arn
  }

  tags = {
    Name  = "application-logs-firehose-${local.vpc_shortname}"
    stack = local.vpc_shortname
    sku   = "shared-services"
  }
}

resource "aws_iam_role" "application_logs-role" {
  name               = "application_logs-role-${local.vpc_shortname}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "application_logs-policy" {
  name   = "application_logs-policy-${local.vpc_shortname}"
  role   = aws_iam_role.application_logs-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "kinesis:Get*",
        "kinesis:DescribeStream"
      ],
      "Resource": "${aws_kinesis_stream.application_logs_stream.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
      ],
      "Resource": [
          "${aws_s3_bucket.application_logs.arn}",
          "${aws_s3_bucket.application_logs.arn}/*",
          "arn:aws:s3:::%FIREHOSE_BUCKET_NAME%",
          "arn:aws:s3:::%FIREHOSE_BUCKET_NAME%/*"
      ]
    }
  ]
}
EOF

}
