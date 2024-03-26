# See additional comments in 10-aws_iam_openid_connect_providers.tf

module "narvar-irsa-role-for-external-dns-eks-devops" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc" # https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-assumable-role-with-oidc
  version = "~> 4.10.1"

  create_role = true
  role_name   = "narvar-irsa-role-for-external-dns-${local.cluster_name_eks-devops}"

  # provider_urls                 = values(local.cluster_name-cluster_oidc_issuer_url-map) # No need to wrap in replace("https://", "") because the module does it for us.
  provider_urls                 = [data.terraform_remote_state.eks-devops.outputs.cluster_oidc_issuer_url] # No need to wrap in replace("https://", "") because the module does it for us.
  role_policy_arns              = [aws_iam_policy.narvar-irsa-policy-for-external-dns-eks-devops.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.service_account_namespace_external_dns}:${local.service_account_name_external_dns}"]

  tags = local.cluster_name-oidc_arn-map
}

data "aws_iam_policy_document" "external-dns-eks-devops" {
  statement {
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = [
      "arn:aws:route53:::hostedzone/${data.terraform_remote_state.infra.outputs.zone_id_devops_narvarcorp_net}",
      # "arn:aws:route53:::hostedzone/${local.private_hosted_zone_id}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "narvar-irsa-policy-for-external-dns-eks-devops" {
  name        = "narvar-irsa-role-for-external-dns-${local.cluster_name_eks-devops}"
  description = "IRSA policy for (cross account) external-dns in ${data.terraform_remote_state.eks-devops.outputs.cluster_arn}"
  policy      = data.aws_iam_policy_document.external-dns-eks-devops.json
}

output "narvar-irsa-role-for-external-dns-eks-devops-iam_role_arn" {
  description = "ARN of IAM role for external-dns"
  value       = module.narvar-irsa-role-for-external-dns-eks-devops.iam_role_arn
}

output "narvar-irsa-role-for-external-dns-eks-devops-iam_role_name" {
  description = "Name of IAM role for external-dns"
  value       = module.narvar-irsa-role-for-external-dns-eks-devops.iam_role_name
}
