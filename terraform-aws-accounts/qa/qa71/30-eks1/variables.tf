#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

variable "aws_region" {
  default = "us-west-2"
}

variable "narvar_terraform_role_arn" {
  default = "arn:aws:iam::472882997329:role/NarvarTerraformRole"
}

variable "terraform_remote_state_infra_config" {
  description = "This block is copied verbatim from ../20-infra/terraform.tf"
  default = {
    bucket         = "tf-8b0c5430-f097-54b8-8e22-2d6eb0c4e0c8"
    key            = "qa/qa71/20-infra/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-8b0c5430-f097-54b8-8e22-2d6eb0c4e0c8-state-lock"
    role_arn       = "arn:aws:iam::472882997329:role/NarvarTerraformRole"
  }
}

variable "cluster_name" {
  default = "eks-qa71"
}

variable "cluster_version" {
  default = "1.21"
}

variable "cluster_timeouts" {
  default = {
    create = "120m"
    update = "120m"
    delete = "120m"
  }
}

variable "cluster_service_ipv4_cidr" {
  description = "https://narvar.atlassian.net/wiki/spaces/devops/pages/122028114/VPC+CIDR"
  default = "172.23.0.0/20"
}

variable "eks_managed_node_group_defaults" {
  type = any
  default = {
    ami_type  = "AL2_x86_64"
    disk_size = 10
    key_name  = "qa71-master"
  }
}

variable "eks_managed_node_groups" {
  description = "See the sample data structure at https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest#usage"
  type        = any
  default = {
    foundation-ingress-ng = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      labels = {
        dedicated = "ingress"
      }

      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "ingress"
          effect = "NO_SCHEDULE"
        }
      }

      update_config = {
        max_unavailable_percentage = 50
      }
    }

    apps1-ng = {
      min_size     = 3
      max_size     = 10
      desired_size = 3

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      update_config = {
        max_unavailable_percentage = 50
      }
    }
  }
}
