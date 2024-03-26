resource "aws_ebs_encryption_by_default" "main" {
  # This is equivalent to:
  #     - https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSEncryption.html#encryption-by-default
  # This will also create (if not exist already) a default AWS Managed Key (with KMS alias 'aws/ebs').
  #
  # See Also:
  #     - https://github.com/narvar/terraform-aws-accounts#51-encryption-for-data-at-rest
  enabled = var.enable_aws_ebs_encryption_by_default
}
