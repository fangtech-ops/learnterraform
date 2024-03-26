locals {
  service_account_namespace_cluster-autoscaler = "narvar-system"                                   # Must match https://github.com/narvar/flux-infra/blob/ce8f8ff026e08344df3bf3102a3c4707f949f3ea/resources/flux-helm-releases/cluster-autoscaler/kustomization.yaml#L7
  service_account_name_cluster-autoscaler      = "cluster-autoscaler-aws-cluster-autoscaler-chart" # Must match https://github.com/narvar/flux-infra/blob/ce8f8ff026e08344df3bf3102a3c4707f949f3ea/resources/flux-helm-releases/cluster-autoscaler/helmrelease.yaml#L50
}

module "narvar-irsa-role-for-cluster-autoscaler" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc" # https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-assumable-role-with-oidc
  version = "~> 4.10.1"

  create_role = true
  role_name   = "narvar-irsa-role-for-cluster-autoscaler"

  provider_url                  = local.cluster_oidc_issuer_url # No need to wrap in replace("https://", "") because the module does it for us.
  role_policy_arns              = [aws_iam_policy.narvar-irsa-policy-for-cluster-autoscaler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.service_account_namespace_cluster-autoscaler}:${local.service_account_name_cluster-autoscaler}"]

  tags = {
    "${local.cluster_name}" : local.oidc_provider_arn
  }
}

resource "aws_iam_policy" "narvar-irsa-policy-for-cluster-autoscaler" {
  name        = "narvar-irsa-role-for-cluster-autoscaler"
  description = "IRSA policy for cluster-autoscaler in ${data.terraform_remote_state.eks.outputs.cluster_arn}"

  # https://docs.aws.amazon.com/eks/latest/userguide/autoscaling.html#ca-create-policy
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
