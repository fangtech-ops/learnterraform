#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

output "account_id" {
  value = local.account_id
}

output "caller_arn" {
  value = replace(data.aws_caller_identity.current.arn, "//\\d+$/", "")
}
