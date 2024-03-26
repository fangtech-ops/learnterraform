#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

resource "github_repository_file" "cm" {
  repository          = "flux-infra"
  branch              = "master"
  file                = var.terraform_configuraton_file
  commit_message      = var.github_repository_file_cm_commit_message
  commit_author       = "Narvar terraform user from Github repo terraform-aws-accounts"
  commit_email        = "terraform@narvar.com"
  overwrite_on_create = true

  content = templatefile(
    "${path.module}/files/templates/configmap.tpl",
    {
      aws_region = var.aws_region

      route53_public_hosted_zone1_domain_name_list = "{${data.terraform_remote_state.networking_infra.outputs.domain_name_dev71_narvarcorp_net}}"
      route53_public_hosted_zone1_id               = data.terraform_remote_state.networking_infra.outputs.zone_id_dev71_narvarcorp_net

      irsa_cert_manager_role_arn       = data.terraform_remote_state.networking_irsa.outputs.narvar-irsa-role-for-cert-manager-eks-dev71-iam_role_arn
      irsa_external_dns_role_arn       = data.terraform_remote_state.networking_irsa.outputs.narvar-irsa-role-for-external-dns-eks-dev71-iam_role_arn
      irsa_cluster_autoscaler_role_arn = module.narvar-irsa-role-for-cluster-autoscaler.iam_role_arn
      irsa_external_secrets_role_arn   = module.narvar-irsa-role-for-external-secrets.iam_role_arn

      eks_cluster_name = local.cluster_name
    }
  )
}
