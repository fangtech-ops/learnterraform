resource "aws_s3_bucket" "default" {
  bucket = "narvar-${local.vpc_shortname}"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name  = "narvar-${local.vpc_shortname}"
    stack = local.vpc_shortname
    sku   = "shared-services"
  }
}

resource "aws_s3_bucket" "narvar-dmz" {
  bucket = "narvar-dmz-${local.vpc_shortname}"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name  = "narvar-dmz-${local.vpc_shortname}"
    stack = local.vpc_shortname
    sku   = "shared-services"
  }
}

resource "aws_s3_bucket" "narvar-returns-upload" {
  bucket = "narvar-returns-upload-${local.vpc_shortname}"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name  = "narvar-returns-upload-${local.vpc_shortname}"
    stack = local.vpc_shortname
    sku   = "returns"
  }
}

resource "aws_iam_user" "s3_user" {
  name = "service_s3_${local.vpc_shortname}"
  path = "/"
}

resource "aws_iam_user_policy" "s3_policy" {
  name   = "s3_policy_${local.vpc_shortname}"
  user   = aws_iam_user.s3_user.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:DeleteObject",
                "s3:DeleteObjectVersion",
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:GetObjectVersion",
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::narvar-${local.vpc_shortname}",
                "arn:aws:s3:::narvar-${local.vpc_shortname}/*",
                "arn:aws:s3:::narvar-dmz-${local.vpc_shortname}",
                "arn:aws:s3:::narvar-dmz-${local.vpc_shortname}/*",
                "arn:aws:s3:::narvar-returns-upload-${local.vpc_shortname}",
                "arn:aws:s3:::narvar-returns-upload-${local.vpc_shortname}/*"
            ]
        }
    ]
}
EOF

}
