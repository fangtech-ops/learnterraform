data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

output "account_id" {
  value = local.account_id
}

output "caller_arn" {
  # See comments in ../20-infra/locals.tf for why calling replace().
  value = replace(data.aws_caller_identity.current.arn, "//\\d+$/", "")
}
