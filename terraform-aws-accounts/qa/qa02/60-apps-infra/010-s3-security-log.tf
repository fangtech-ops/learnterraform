
# S3 bucket
resource "aws_s3_bucket" "security-log" {
  bucket = "security-log-${local.vpc_shortname}"
  # acl    = "private" # Deprecated; replaced by "aws_s3_bucket_acl" below.

  # The 'server_side_encryption_configuration' inner block is deprecated;
  # supposedly to be replaced by first class resource "aws_s3_bucket_server_side_encryption_configuration" below.
  # But somehow I'm not able to switch to the new code -- each successive 'terraform apply'
  # keeps flipping this block back and forth.
  #   -- Vincent Yin, March 2022
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name  = "security-log-${local.vpc_shortname}"
    stack = local.vpc_shortname
    sku   = "devops"
  }
}

# resource "aws_s3_bucket_server_side_encryption_configuration" "security-log" {
#   bucket = aws_s3_bucket.security-log.bucket
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm     = "AES256"
#     }
#   }
# }

resource "aws_s3_bucket_acl" "security-log" {
  bucket = aws_s3_bucket.security-log.id
  acl    = "private"
}
