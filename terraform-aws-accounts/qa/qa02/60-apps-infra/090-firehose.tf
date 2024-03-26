resource "aws_s3_bucket" "narvar-kinesis" {
  bucket        = "narvar-kinesis-${local.vpc_shortname}"
  acl           = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name  = "narvar-kinesis-${local.vpc_shortname}"
    stack = local.vpc_name
    sku   = "data-services"
  }
}

resource "aws_s3_bucket" "narvar-live-tracking" {
  bucket        = "narvar-live-tracking-${local.vpc_shortname}"
  acl           = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name  = "narvar-kinesis-${local.vpc_shortname}"
    stack = local.vpc_name
    sku   = "track"
  }
}

resource "aws_s3_bucket" "narvar-orders-api-request-payload" {
  bucket        = "narvar-orders-api-request-payload-${local.vpc_shortname}"
  acl           = "private"
  force_destroy = true

  tags = {
    Name  = "narvar-orders-api-request-payload-${local.vpc_shortname}"
    stack = local.vpc_name
    sku   = "data-services"
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket" "narvar-gap-poc-bucket" {
  bucket        = "narvar-gap-poc-bucket-${local.vpc_shortname}"
  acl           = "private"
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = {
    Name  = "narvar-gap-poc-bucket-${local.vpc_shortname}"
    stack = local.vpc_name
    sku   = "data-services"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "orders-api-request-payload" {
  name        = "orders-api-request-payload-${local.vpc_shortname}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose-role.arn
    bucket_arn         = aws_s3_bucket.narvar-orders-api-request-payload.arn
    prefix             = "data/"
    compression_format = "UNCOMPRESSED"
    buffer_size        = 10
    buffer_interval    = 300
  }

  tags = {
    Name  = "orders-api-request-payload-${local.vpc_shortname}"
    stack = local.vpc_shortname
    sku   = "data-services"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "tracking-banners" {
  name        = "tracking-banners-${local.vpc_shortname}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose-role.arn
    bucket_arn         = aws_s3_bucket.narvar-kinesis.arn
    prefix             = "banners/"
    compression_format = "UNCOMPRESSED"
    buffer_size        = 10
    buffer_interval    = 300
  }

  tags = {
    Name  = "tracking-banners-${local.vpc_shortname}"
    stack = local.vpc_shortname
    sku   = "track"
  }

}

resource "aws_kinesis_firehose_delivery_stream" "tracking-feedback" {
  name        = "tracking-feedback-${local.vpc_shortname}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose-role.arn
    bucket_arn         = aws_s3_bucket.narvar-kinesis.arn
    prefix             = "feedback/"
    compression_format = "UNCOMPRESSED"
    buffer_size        = 10
    buffer_interval    = 300
  }

  tags = {
    Name  = "tracking-feedback-${local.vpc_shortname}"
    stack = local.vpc_shortname
    sku   = "track"
  }

}

resource "aws_kinesis_firehose_delivery_stream" "tracking-views" {
  name        = "tracking-views-${local.vpc_shortname}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose-role.arn
    bucket_arn         = aws_s3_bucket.narvar-kinesis.arn
    prefix             = "views/"
    compression_format = "UNCOMPRESSED"
    buffer_size        = 10
    buffer_interval    = 300
  }

  tags = {
    Name  = "tracking-views-${local.vpc_shortname}"
    stack = local.vpc_shortname
    sku   = "track"
  }

}

resource "aws_kinesis_firehose_delivery_stream" "live-tracking" {
  name        = "live-tracking-${local.vpc_shortname}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose-role.arn
    bucket_arn         = aws_s3_bucket.narvar-live-tracking.arn
    prefix             = "data/"
    compression_format = "UNCOMPRESSED"
    buffer_size        = 10
    buffer_interval    = 300
  }

  tags = {
    Name  = "live-tracking-${local.vpc_shortname}"
    stack = local.vpc_shortname
    sku   = "track"
  }

}

resource "aws_kinesis_firehose_delivery_stream" "live-tracking-incremental" {
  name        = "live-tracking-incremental-${local.vpc_shortname}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose-role.arn
    bucket_arn         = aws_s3_bucket.narvar-live-tracking-incremental.arn
    prefix             = "data/"
    compression_format = "UNCOMPRESSED"
    buffer_size        = 10
    buffer_interval    = 300
  }

  tags = {
    Name  = "live-tracking-incremental-${local.vpc_shortname}"
    stack = local.vpc_shortname
    sku   = "track"
  }

}

resource "aws_s3_bucket" "narvar-live-tracking-incremental" {
  bucket        = "narvar-live-tracking-incremental-${local.vpc_shortname}"
  acl           = "private"
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = {
    Name  = "narvar-kinesis-${local.vpc_shortname}"
    stack = local.vpc_name
    sku   = "track"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "gap-poc-stream" {
  name        = "gap-poc-stream-${local.vpc_shortname}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose-role.arn
    bucket_arn         = aws_s3_bucket.narvar-gap-poc-bucket.arn
    prefix             = "data/"
    compression_format = "UNCOMPRESSED"
    buffer_size        = 10
    buffer_interval    = 300
  }

  tags = {
    Name  = "gap-poc-stream-${local.vpc_shortname}"
    stack = local.vpc_shortname
    sku   = "data-services"
  }

}

resource "aws_iam_role" "firehose-role" {
  name               = "firehose-role-${local.vpc_shortname}"
  description        = "Managed by Terraform"
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

resource "aws_iam_role_policy" "firehose_global_policy" {
  name   = "firehose_global_policy"
  role   = aws_iam_role.firehose-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
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
        "arn:aws:s3:::narvar-kinesis-${local.vpc_shortname}",
        "arn:aws:s3:::narvar-kinesis-${local.vpc_shortname}/*",
        "arn:aws:s3:::narvar-live-tracking-${local.vpc_shortname}",
        "arn:aws:s3:::narvar-live-tracking-${local.vpc_shortname}/*",
        "arn:aws:s3:::narvar-live-tracking-incremental-${local.vpc_shortname}",
        "arn:aws:s3:::narvar-live-tracking-incremental-${local.vpc_shortname}/*",
        "arn:aws:s3:::narvar-orders-api-request-payload-${local.vpc_shortname}",
        "arn:aws:s3:::narvar-orders-api-request-payload-${local.vpc_shortname}/*",
        "arn:aws:s3:::%FIREHOSE_BUCKET_NAME%",
        "arn:aws:s3:::%FIREHOSE_BUCKET_NAME%/*"
      ]
    }
  ]
}
EOF

}
