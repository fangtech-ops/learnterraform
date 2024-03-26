resource "aws_s3_bucket" "ms_atlas" {
  bucket = "narvar-ms-atlas-${local.vpc_shortname}"
  # acl    = "private"

  # See comment in 010-security_log_s3.tf
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = {
    Name  = "ms-atlas-${local.vpc_shortname}"
    stack = local.vpc_shortname
    sku   = "data-platform"
  }
}

resource "aws_s3_bucket_acl" "ms_atlas" {
  bucket = aws_s3_bucket.ms_atlas.id
  acl    = "private"
}

resource "aws_kinesis_stream" "ms_atlas_carrier_input" {
  name             = "ms-atlas-carrier-input-${local.vpc_shortname}"
  shard_count      = 1
  retention_period = 24
  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]
  tags = {
    Name  = "ms-atlas-carrier-input-${local.vpc_shortname}"
    stack = local.vpc_shortname
    sku   = "data-services"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "ms_atlas_carrier_input_firehose" {
  name        = "ms-atlas-carrier-input-firehose-${local.vpc_shortname}"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.ms_atlas_carrier_input.arn
    role_arn           = aws_iam_role.ms_atlas-role.arn
  }

  extended_s3_configuration {
    role_arn           = aws_iam_role.ms_atlas-role.arn
    bucket_arn         = aws_s3_bucket.ms_atlas.arn
    prefix             = "input/"
    compression_format = "UNCOMPRESSED"
    buffer_size        = 10
    buffer_interval    = 300
  }

  tags = {
    Name  = "ms-atlas-carrier-input-firehose-${local.vpc_shortname}"
    stack = local.vpc_shortname
    sku   = "data-services"
  }

}

resource "aws_kinesis_stream" "ms_atlas_output" {
  name             = "ms-atlas-output-${local.vpc_shortname}"
  shard_count      = 2
  retention_period = 24
  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]
  tags = {
    Name  = "ms-atlas-output-${local.vpc_shortname}"
    stack = local.vpc_shortname
    sku   = "data-services"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "ms_atlas_output_firehose" {
  name        = "ms-atlas-output-firehose-${local.vpc_shortname}"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.ms_atlas_output.arn
    role_arn           = aws_iam_role.ms_atlas-role.arn
  }

  extended_s3_configuration {
    role_arn           = aws_iam_role.ms_atlas-role.arn
    bucket_arn         = aws_s3_bucket.ms_atlas.arn
    prefix             = "output/"
    compression_format = "UNCOMPRESSED"
    buffer_size        = 10
    buffer_interval    = 300
  }

  tags = {
    Name  = "ms-atlas-output-firehose-${local.vpc_shortname}"
    stack = local.vpc_shortname
    sku   = "data-services"
  }

}

resource "aws_iam_role" "ms_atlas-role" {
  name               = "ms_atlas-role-${local.vpc_shortname}"
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

resource "aws_iam_role_policy" "ms_atlas-policy" {
  name   = "ms_atlas-policy-${local.vpc_shortname}"
  role   = aws_iam_role.ms_atlas-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "kinesis:Put*",
        "kinesis:Get*",
        "kinesis:DescribeStream"
      ],
      "Resource": [
        "arn:aws:kinesis:${var.aws_region}:${local.account_id}:stream/ms-atlas-output-${local.vpc_shortname}",
        "arn:aws:kinesis:${var.aws_region}:${local.account_id}:stream/ms-atlas-carrier-input-${local.vpc_shortname}"
      ]
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
          "${aws_s3_bucket.ms_atlas.arn}",
          "${aws_s3_bucket.ms_atlas.arn}/*",
          "arn:aws:s3:::%FIREHOSE_BUCKET_NAME%",
          "arn:aws:s3:::%FIREHOSE_BUCKET_NAME%/*"
      ]
    }
  ]
}
EOF

}
