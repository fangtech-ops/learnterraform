# Cross-account IRSA role:
#   - https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts-technical-overview.html#cross-account-access
#     It lists 2 methods:
#         1) creating an identity provider from another account's cluster
#         2) using chained AssumeRole operations
#     We are using Method 1.
#
#   - https://aws.amazon.com/blogs/containers/cross-account-iam-roles-for-kubernetes-service-accounts/
#     Its "IRSA procedure" step 1 says to run this command in the "developer" account (i.e., EKS account):
#         $ eksctl utils associate-iam-oidc-provider —name development-cluster --approve
#     That is unnecessary/useless. The blog ends up creating 2 OIDC providers, one in each AWS account.
#     As described in the AWS docs above (Method 1 in the previous URL), we only need to create 1 OIDC provider
#     and it should be created in the non-EKS account.
#     P.S. The blog has other problems:
#         1) The above 'eksctl' command is not only useless but also contains a typo: '--name' should be '--cluster'.
#         2) The blog shows this trust policy snippet:
#                "Condition": {
#                  "StringEquals": {
#                    "oidc.eks.us-east-1.amazonaws.com/id/oidc-id:aud": "sts.amazonaws.com"
#                  }
#                }
#            Although not wrong, that is not as tight as what the AWS docs (the previous URL) shows, i.e.,
#                "Condition": {
#                  "StringEquals": {
#                    "oidc.eks.us-east-1.amazonaws.com/id/oidc-id:sub": "system:serviceaccount:<NAMESPACE>:<SA NAME>"
#                  }
#                }
#     So, 3 problems in 1 blog. That's pretty bad especially on an advanced and tricky topic where accuracy is the key!


# This is Method 1 in the above AWS docs (1st URL).
# This creates an IAM Identity Provider (IdP) which can be seen in "IAM Console => Access Management => Identity providers".
# The ARN is in the form of "arn:aws:iam::NETWORKING_ACCOUNT_ID:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/F0CFC2B3E988784CD3B1B29AB7638048".
#
# This IAM IdP allows a Kubernetes Service Account (SA) identity (where Kubernetes is the OIDC IdP) to assume an AWS IAM role, 
# therefore crossing the identity boundary between Kubernetes IdP and AWS IAM IdP.
#
# In our case, such an AWS IAM role is kinda like a cross-account role -- the EKS cluster  
# resides in 'devops' account while the IAM role (as well as the IAM IdP based on OIDC) resides in 'networking' account. 
#   - Kubernetes SAs will be created later by manifests yaml in Github repo 'flux-infra'.
#   - AWS IAM roles  will be created by various *.tf in this folder.
resource "aws_iam_openid_connect_provider" "oidc-from-eks" {
  for_each = local.cluster_name-cluster_oidc_issuer_url-map

  url            = each.value
  client_id_list = ["sts.amazonaws.com"]

  # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/e90c877a741ab3cc4215376a70f7bcc360b6a3d2/variables.tf#L374-L378
  # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/e90c877a741ab3cc4215376a70f7bcc360b6a3d2/irsa.tf#L3-L8
  # https://github.com/hashicorp/terraform-provider-aws/issues/10104#issuecomment-551079323
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]

  tags = {
    Name           = "${each.key}-eks-irsa" # Not the most descriptive value, but same as would be tagged by terraform-aws-modules/terraform-aws-eks.
    Purpose        = "Cross-account IRSA for EKS"
    EKSClusterName = each.key
    EKSAccountID   = local.cluster_name-account_id-map[each.key]
  }
}

locals {
  cluster_name-oidc_arn-map = {
    for name, value in aws_iam_openid_connect_provider.oidc-from-eks :
    name => value.arn
  }
}

output "cluster_name-oidc_arn-map" {
  value = local.cluster_name-oidc_arn-map
}
