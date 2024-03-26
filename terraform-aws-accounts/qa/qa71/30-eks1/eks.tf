#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

data "terraform_remote_state" "infra" {
  backend = "s3"
  config  = var.terraform_remote_state_infra_config
}

locals {
  vpc_id = data.terraform_remote_state.infra.outputs.vpc1-vpc_id

  private_subnets = data.terraform_remote_state.infra.outputs.vpc1-private_subnets
}

output "vpc_id" {
  value = local.vpc_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.2.3"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

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
  }

  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn
      resources        = ["secrets"]
    }
  ]

  cluster_security_group_additional_rules = {
    narvar_aws_client_vpn_access = {
      description = "Narvar AWS Client VPN access to Kubernetes API"
      cidr_blocks = ["10.70.0.0/24"]
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
    }
  }

  node_security_group_additional_rules = {
    ingress_10_x_x_x = {
      description = "Allow all private IP, all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"

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

  enable_irsa = true

  eks_managed_node_group_defaults = var.eks_managed_node_group_defaults
  eks_managed_node_groups         = var.eks_managed_node_groups

  cluster_timeouts = var.cluster_timeouts

  tags = { test = "Atlantis dummy test" }
}

output "cluster_name" {
  value = var.cluster_name
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
