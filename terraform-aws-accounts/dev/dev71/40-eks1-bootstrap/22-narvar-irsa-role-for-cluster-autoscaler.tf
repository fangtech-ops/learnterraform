#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

locals {
  service_account_namespace_cluster-autoscaler = "narvar-system"
  service_account_name_cluster-autoscaler      = "cluster-autoscaler-aws-cluster-autoscaler-chart"
}

module "narvar-irsa-role-for-cluster-autoscaler" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 4.10.1"

  create_role = true
  role_name   = "narvar-irsa-role-for-cluster-autoscaler"

  provider_url                  = local.cluster_oidc_issuer_url
  role_policy_arns              = [aws_iam_policy.narvar-irsa-policy-for-cluster-autoscaler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.service_account_namespace_cluster-autoscaler}:${local.service_account_name_cluster-autoscaler}"]

  tags = {
    "${local.cluster_name}" : local.oidc_provider_arn
  }
}

resource "aws_iam_policy" "narvar-irsa-policy-for-cluster-autoscaler" {
  name        = "narvar-irsa-role-for-cluster-autoscaler"
  description = "IRSA policy for cluster-autoscaler in ${data.terraform_remote_state.eks.outputs.cluster_arn}"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:DescribeTags",
            "autoscaling:SetDesiredCapacity",
            "autoscaling:TerminateInstanceInAutoScalingGroup",
            "ec2:DescribeLaunchTemplateVersions"
          ],
          "Resource" : "*",
          "Effect" : "Allow"
        }
      ]
    }
  )
}

output "narvar-irsa-role-for-cluster-autoscaler-iam_role_arn" {
  description = "ARN of IAM role for cluster-autoscaler"
  value       = module.narvar-irsa-role-for-cluster-autoscaler.iam_role_arn
}

output "narvar-irsa-role-for-cluster-autoscaler-iam_role_name" {
  description = "Name of IAM role for cluster-autoscaler"
  value       = module.narvar-irsa-role-for-cluster-autoscaler.iam_role_name
}
