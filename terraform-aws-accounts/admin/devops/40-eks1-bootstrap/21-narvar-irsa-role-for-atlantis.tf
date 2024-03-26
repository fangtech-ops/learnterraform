locals {
  service_account_namespace_atlantis = "atlantis" # Must match https://github.com/narvar/flux-infra/blob/ce8f8ff026e08344df3bf3102a3c4707f949f3ea/resources/flux-helm-releases/atlantis/kustomization.yaml#L3
  service_account_name_atlantis      = "atlantis" # Must match https://github.com/narvar/flux-infra/blob/ce8f8ff026e08344df3bf3102a3c4707f949f3ea/resources/flux-helm-releases/atlantis/helmrelease.yaml#L78
}

module "narvar-irsa-role-for-atlantis" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc" # https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-assumable-role-with-oidc
  version = "~> 4.10.1"

  create_role = true
  role_name   = "narvar-irsa-role-for-atlantis"

  provider_url                  = local.cluster_oidc_issuer_url # No need to wrap in replace("https://", "") because the module does it for us.
  role_policy_arns              = [aws_iam_policy.narvar-irsa-policy-for-atlantis.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.service_account_namespace_atlantis}:${local.service_account_name_atlantis}"]

  tags = {
    "${local.cluster_name}" : local.oidc_provider_arn
  }
}

resource "aws_iam_policy" "narvar-irsa-policy-for-atlantis" {
  name        = "narvar-irsa-role-for-atlantis"
  description = "IRSA policy for atlantis in ${data.terraform_remote_state.eks.outputs.cluster_arn}"

  # This IRSA role doesn't directly have any privilege except for (cross-account) AssumeRole.
  # With such AssumeRole privilege, Atlantis can execute 'terraform apply' inside any folder of
  # this Github repo ('terraform-aws-accounts') which targets another AWS account.
  #
  # Specifically, each terraform folder's providers.tf has this block:
  #      provider "aws" {
  #          assume_role {
  #              role_arn = var.narvar_terraform_role_arn
  #          }
  #          ...
  #      }
  # which is (for majority of accounts) a cross-account AssumeRole operation.
  # That block causes terraform to switch into the correct destination AWS account
  # for us regardless of which AMI CLI Profile we used to launch 'terraform apply'.
  #
  # The AssumeRole operation looks like this:
  #   (A) Initiator role (this IRSR role in devops account) ===(AssumeRole)===> (B) Destination role (e.g., dev71's NarvarTerraformRole)
  #
  # In order for the AssumeRole operation (depicted above) to succeed, two IAM permissions need to be granted:
  #   (B) The destination account's NarvarTerraformRole needs to have an IAM trust policy that accepts AssumeRole
  #       operation initiated from our IRSR role (i.e., this IRSA role).
  #       That privilege is granted in every destination account's terraform, e.g., /dev/dev71/10-bootstrap/iam.tf.
  #   (A) The initiator's AWS Account ('devops') needs to grant the Atlantis IAM identity (this IRSA role) the privilege
  #       to initiate the AssumeRole operation toward the target (cross-account) role. That's what we're doing below.
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "sts:AssumeRole",
          "Resource" : [
            "arn:aws:iam::905426566754:role/NarvarTerraformRole", # account: 'doitintl-payer-49' (Billing Account)
            "arn:aws:iam::106628749228:role/NarvarTerraformRole", # account: 'devops'
            "arn:aws:iam::580941417126:role/NarvarTerraformRole", # account: 'networking'
            "arn:aws:iam::342812538696:role/NarvarTerraformRole", # account: 'dev71'
            "arn:aws:iam::472882997329:role/NarvarTerraformRole", # account: 'qa71'
          ]
        }
      ]
    }
  )
}

output "narvar-irsa-role-for-atlantis-iam_role_arn" {
  description = "ARN of IAM role for atlantis"
  value       = module.narvar-irsa-role-for-atlantis.iam_role_arn
}

output "narvar-irsa-role-for-atlantis-iam_role_name" {
  description = "Name of IAM role for atlantis"
  value       = module.narvar-irsa-role-for-atlantis.iam_role_name
}
