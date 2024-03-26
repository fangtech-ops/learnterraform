
# S3 bucket
resource "aws_s3_bucket" "freighter" {
  bucket = "narvar-freighter-${local.vpc_shortname}"
  # acl    = "private" # Deprecated; replaced by "aws_s3_bucket_acl" below.

  # See comment in qa02/60-apps-infra/010-s3-security-log
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
  tags = {
    Name  = "narvar-freighter-${local.vpc_shortname}"
    stack = local.vpc_shortname
    sku   = "track"
  }
}

resource "aws_s3_bucket_acl" "freighter" {
  bucket = aws_s3_bucket.freighter.id
  acl    = "private"
}
