data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

output "account_id" {
  value = local.account_id
}

# See comments in ../20-infra/locals.tf
output "caller_arn" {
  value = replace(data.aws_caller_identity.current.arn, "//\\d+$/", "")
}


locals {
  cluster_name_eks-devops = data.terraform_remote_state.eks-devops.outputs.cluster_name
  cluster_name_eks-dev71  = data.terraform_remote_state.eks-dev71.outputs.cluster_name
  cluster_name_eks-qa71  = data.terraform_remote_state.eks-qa71.outputs.cluster_name
  cluster_name_eks-st71  = data.terraform_remote_state.eks-st71.outputs.cluster_name

  # public_hosted_zone_id = data.terraform_remote_state.infra.outputs.zone_id_devops_narvarcorp_net
  # private_hosted_zone_id = data.terraform_remote_state.infra.outputs.xxxxxx

  cluster_name-cluster_oidc_issuer_url-map = {
    "${data.terraform_remote_state.eks-devops.outputs.cluster_name}" : data.terraform_remote_state.eks-devops.outputs.cluster_oidc_issuer_url,
    "${data.terraform_remote_state.eks-dev71.outputs.cluster_name}" : data.terraform_remote_state.eks-dev71.outputs.cluster_oidc_issuer_url,
    "${data.terraform_remote_state.eks-qa71.outputs.cluster_name}" : data.terraform_remote_state.eks-qa71.outputs.cluster_oidc_issuer_url,
    "${data.terraform_remote_state.eks-st71.outputs.cluster_name}" : data.terraform_remote_state.eks-st71.outputs.cluster_oidc_issuer_url
  }

  cluster_name-account_id-map = {
    "${data.terraform_remote_state.eks-devops.outputs.cluster_name}" : data.terraform_remote_state.eks-devops.outputs.account_id,
    "${data.terraform_remote_state.eks-dev71.outputs.cluster_name}" : data.terraform_remote_state.eks-dev71.outputs.account_id,
    "${data.terraform_remote_state.eks-qa71.outputs.cluster_name}" : data.terraform_remote_state.eks-qa71.outputs.account_id,
    "${data.terraform_remote_state.eks-st71.outputs.cluster_name}" : data.terraform_remote_state.eks-st71.outputs.account_id
  }
}
