# ................... aws_caller_identity ...................................
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


# ................... terraform_remote_state.eks ................................
data "terraform_remote_state" "eks" { # https://www.terraform.io/docs/language/settings/backends/s3.html#data-source-configuration
  backend = "s3"
  config  = var.terraform_remote_state_eks_config
}

locals {
  cluster_name = data.terraform_remote_state.eks.outputs.cluster_name # e.g., 'eks-devops'
}

data "aws_eks_cluster" "eks1" {
  name = local.cluster_name
}

locals {
  cluster_id              = data.aws_eks_cluster.eks1.id
  oidc_provider_arn       = data.terraform_remote_state.eks.outputs.oidc_provider_arn
  cluster_oidc_issuer_url = data.terraform_remote_state.eks.outputs.cluster_oidc_issuer_url
  cluster_account_id      = data.terraform_remote_state.eks.outputs.account_id # Should == current account_id, but get it from the authoratative source anyway.

  scripts_dir         = "${path.module}/files/scripts"
  kubeconfig_filename = "kubeconfig_${local.cluster_name}"
}


# ................... terraform_remote_state.networking ................................
data "terraform_remote_state" "networking_infra" { # https://www.terraform.io/docs/language/settings/backends/s3.html#data-source-configuration
  backend = "s3"
  config  = var.terraform_remote_state_networking_infra_config
}

data "terraform_remote_state" "networking_irsa" { # https://www.terraform.io/docs/language/settings/backends/s3.html#data-source-configuration
  backend = "s3"
  config  = var.terraform_remote_state_networking_irsa_config
}
