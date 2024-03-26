#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "eks" {
  backend = "s3"
  config  = var.terraform_remote_state_eks_config
}

locals {
  application_name = "atlas-data-deletion"

  account_id   = data.aws_caller_identity.current.account_id
  cluster_name = data.terraform_remote_state.eks.outputs.cluster_name

  cluster_oidc_issuer_url = data.terraform_remote_state.eks.outputs.cluster_oidc_issuer_url
  oidc_provider_arn       = data.terraform_remote_state.eks.outputs.oidc_provider_arn
}

output "account_id" {
  value = local.account_id
}

output "caller_arn" {
  value = replace(data.aws_caller_identity.current.arn, "//\\d+$/", "")
}
