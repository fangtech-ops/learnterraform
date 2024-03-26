#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

resource "aws_ebs_encryption_by_default" "main" {
  enabled = var.enable_aws_ebs_encryption_by_default
}
