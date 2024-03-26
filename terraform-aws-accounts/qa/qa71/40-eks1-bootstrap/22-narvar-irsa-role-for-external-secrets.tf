#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

locals {
  service_account_namespace_external-secrets = "narvar-system"
  service_account_name_external-secrets      = "external-secrets-chart"
}

module "narvar-irsa-role-for-external-secrets" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 4.10.1"

  create_role = true
  role_name   = "narvar-irsa-role-for-external-secrets"

  provider_url                  = local.cluster_oidc_issuer_url
  role_policy_arns              = [aws_iam_policy.narvar-irsa-policy-for-external-secrets.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.service_account_namespace_external-secrets}:${local.service_account_name_external-secrets}"]

  tags = {
    "${local.cluster_name}" : local.oidc_provider_arn
  }
}

resource "aws_iam_policy" "narvar-irsa-policy-for-external-secrets" {
  name        = "narvar-irsa-role-for-external-secrets"
  description = "IRSA policy for external-secrets in ${data.terraform_remote_state.eks.outputs.cluster_arn}"

  policy = data.aws_iam_policy_document.narvar-irsa-policy-for-external-secrets.json
}

# https://docs.aws.amazon.com/mediaconnect/latest/ug/iam-policy-examples-asm-secrets.html
# https://docs.aws.amazon.com/secretsmanager/latest/userguide/auth-and-access_examples.html

data "aws_iam_policy_document" "narvar-irsa-policy-for-external-secrets" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
    ]
    resources = ["arn:aws:secretsmanager:${var.aws_region}:${local.account_id}:secret:${local.cluster_name}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:ListSecrets",
    ]
    resources = ["*"]
  }

}

output "narvar-irsa-role-for-external-secrets-iam_role_arn" {
  description = "ARN of IAM role for external-secrets"
  value       = module.narvar-irsa-role-for-external-secrets.iam_role_arn
}

output "narvar-irsa-role-for-external-secrets-iam_role_name" {
  description = "Name of IAM role for external-secrets"
  value       = module.narvar-irsa-role-for-external-secrets.iam_role_name
}
