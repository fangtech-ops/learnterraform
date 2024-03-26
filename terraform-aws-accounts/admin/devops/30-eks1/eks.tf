# To delete the EKS cluster, do:
#   1) If ../40-eks1-bootstrap exists, go there to do 'terraform destroy' first.
#   2) Then, here in this folder, do:
#         $ terraform destroy -target module.eks
#
# To recreate an EKS cluster:
#   - https://github.com/narvar/terraform-aws-accounts#322-example-of-command-sequence-for-recreating-an-eks-cluster


# ..................................... Retrieve VPC Info ...........................................

data "terraform_remote_state" "infra" { # https://www.terraform.io/docs/language/settings/backends/s3.html#data-source-configuration
  backend = "s3"
  config  = var.terraform_remote_state_infra_config
}

locals {
  # Cannot do:
  #   vpc_id = data.terraform_remote_state.infra.module.vpc1.vpc_id
  # because:
  #   https://www.terraform.io/docs/language/state/remote-state-data.html#root-outputs-only
  vpc_id = data.terraform_remote_state.infra.outputs.vpc1-vpc_id

  # This is why we use "terraform_remote_state" to retrieve the VPC info rather than looking up the VPC via the "aws_vpc" data source.
  # It is pretty difficult (and non-foolproof anyay) to figure out which subnet is "private" via AWS CLI (and almost impossible via terraform)
  # because being "private" is a design pattern rather than an explicit attribute of a subnet resource.
  # Only this terraform_remote_state has the "inside knowledge" of which subnets are deemed "private".
  #
  # Retrieving a list of private subnets is just one example. As we evolve this EKS cluster in the future,
  # we might need to retrieve other "inside knowledge" from this terraform_remote_state which might not be easily queried
  # via (generic) terraform data sources.
  private_subnets = data.terraform_remote_state.infra.outputs.vpc1-private_subnets
}

output "vpc_id" {
  value = local.vpc_id
}

# ..................................... EKS ...........................................
# Our naming convention and coding pattern achieve these goals:
#   - Terraform resource names (e.g., module name "eks" which appears in terraform.tfstate file) are generically named.
#     This makes terraform source code identical across AWS accounts.
#   - AWS resource names (e.g., something like "eks-devops" as shown in AWS Admin Console) are/can be meaningful.
#     This is the 'cluster_name' attribute in the following module. Its value comes from var.cluster_name.
# This is very similar to the strategy we use for VPC (see ./20-infra/10-vpc.tf).
module "eks" {
  # In this block, the order of params generally follows that of:
  #   - https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v18.2.1/examples/eks_managed_node_group/main.tf

  source  = "terraform-aws-modules/eks/aws" # https://registry.terraform.io/modules/terraform-aws-modules/eks
  version = "~> 18.2.3"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = true  # https://github.com/terraform-aws-modules/terraform-aws-eks#input_cluster_endpoint_private_access
  cluster_endpoint_public_access  = false # https://github.com/terraform-aws-modules/terraform-aws-eks#input_cluster_endpoint_public_access

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }

    # # Before the end of 2021, AWS had only 3 possible add-ons: "kube-proxy", "vpc-cni", and "coredns".
    # #
    # # On Dec 9, 2021, AWS announced the 4th add-on which is a better disk option:
    # #   - EBS CSI driver now available in EKS add-ons in preview
    # #     https://aws.amazon.com/about-aws/whats-new/2021/12/eks-add-ons-ebs-csi-driver/
    # #
    # # The add-on's exact name is "aws-ebs-csi-driver".
    # # The exact name can be obtained like this:
    # #   $ aws eks describe-addon-versions | grep addonName | sort
    # #             "addonName": "aws-ebs-csi-driver",
    # #             "addonName": "coredns",
    # #             "addonName": "kube-proxy",
    # #             "addonName": "vpc-cni",
    # #
    # # In order to use the "aws-ebs-csi-driver", more configuration is needed (at this "preview" stage at least):
    # #   - https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html
    # # To avoid the above hassle (and let the dust settle until the "preview" stage ends),
    # # we choose not to install that addon for now.
    # # If/when we choose to install it, we might need to revisit the default 'kind: StorageClass'.
    #
    # aws-ebs-csi-driver = {
    #   resolve_conflicts = "OVERWRITE"
    # }
  }

  # https://aws.amazon.com/blogs/containers/using-eks-encryption-provider-support-for-defense-in-depth/
  #
  # I think this feature can easily be misunderstood. My clarification...
  #
  # It doesn't mean that a developer is henceforth prevented from seeing the cleartext secret. 'kubectl get secret ...' still returns
  # a value that is the base64 encoded cleartext (not ciphertext). Therefore, it can be readily decoded as demonstrated in
  # the above blog with the command 'kubectl get secret ... | base64 —decode'.
  #
  # What this feature accomplishes is to encrypt the (previously unencrypted) runtime Etcd data in memory in the Control Plane,
  # as demonstrated in the CloudTrail screenshot in the blog. Prior to this feature, if a hacker or an AWS backend engineer
  # gained a direct connection to our runtime K8s master node's Etcd server (e.g., using 'etcdctl' CLI from somewhere on the network),
  # then he would have been able to readily download the cleartext (albeit base64 encoded) secrets from Etcd server.
  # Such a cleartext secret could be a password to Narvar database, for example.
  # (Note: the data on disk has always been encrypted by AWS/EKS and isn't the motivation of this feature although this feature
  # has the side effect of causing the data on disk to be double encrypted.)
  #
  # Furthermore, this feature adopts the design pattern of envelope encryption (i.e., our CMK doesn't directly encrypt the Etcd data;
  # rather, our CMK generates a per-item Data Key which in turn encrypts the Etcd data), but that's a secondary enhancement,
  # not the heart/motivation of this feature.
  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn
      resources        = ["secrets"]
    }
  ]

  cluster_security_group_additional_rules = {
    narvar_aws_client_vpn_access = {
      description = "Narvar AWS Client VPN access to Kubernetes API"
      cidr_blocks = ["10.70.0.0/24"] # https://github.com/narvar/terraform-aws-accounts/tree/main/admin/networking/20-infra#13-understanding-source-nat-of-aws-client-vpn
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
    }
  }

  node_security_group_additional_rules = {
    ingress_10_x_x_x = {
      # The sample code at https://github.com/terraform-aws-modules/terraform-aws-eks#security-groups
      # demonstrates a wide-open SG rule for *intra*-nodegroup traffic, but doesn't allow cross-nodegroup traffic.
      # Our own rule here allows cross-nodegroup traffic, too.
      # For example, this rule allows the dedicated ingress nodegroup ('foundation-ingress-ng')
      # to exchange traffic with other nodegroups.
      description = "Allow all private IP, all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"

      # I haven't bothered to narrow this down further. But if I did, it would need to cover at least the following CIDRs:
      #   - From node to node (including cross-node-group), any port/protocol. So, the CIDRs for all private subnets.
      #   - From all public subnets (where public-ingress-controller generated AWS NLB is) to private subnets (where EKS nodes are.)
      #   - From jump-vpc (AWS Client VPN) to private subnets (where EKS nodes are) on TCP port 22 (ssh).
      cidr_blocks = ["10.0.0.0/8"]
    }

    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  vpc_id                    = local.vpc_id
  subnet_ids                = local.private_subnets
  cluster_service_ipv4_cidr = var.cluster_service_ipv4_cidr

  enable_irsa = true # Default: false

  eks_managed_node_group_defaults = var.eks_managed_node_group_defaults
  eks_managed_node_groups         = var.eks_managed_node_groups

  cluster_timeouts = var.cluster_timeouts

  tags = { test = "Atlantis dummy test" }
}

output "cluster_name" {
  value = var.cluster_name # e.g., 'eks-devops'
}

output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "aws_auth_configmap_yaml" {
  value = module.eks.aws_auth_configmap_yaml
}

# ..................................... Supporting Resources ...........................................

resource "aws_kms_key" "eks" {
  description             = "Narvar CMK for encrypting EKS 'kind:secret' for ${var.cluster_name}"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_kms_alias" "eks" {
  name          = "alias/narvar-cmk-${var.cluster_name}"
  target_key_id = aws_kms_key.eks.key_id
}
