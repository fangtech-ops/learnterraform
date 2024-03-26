variable "aws_region" {
  default = "us-west-2"
}

variable "narvar_terraform_role_arn" {
  default = "arn:aws:iam::106628749228:role/NarvarTerraformRole"
}

variable "terraform_remote_state_infra_config" {
  description = "This block is copied verbatim from ../20-infra/terraform.tf"
  default = {
    bucket         = "tf-6d5612ed-1736-5d4e-a92f-7fe7df219d0d"
    key            = "admin/devops/20-infra/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-6d5612ed-1736-5d4e-a92f-7fe7df219d0d-state-lock"
    role_arn       = "arn:aws:iam::106628749228:role/NarvarTerraformRole" # i.e., var.narvar_terraform_role_arn
  }
}

variable "cluster_name" {
  default = "eks-devops"
}

variable "cluster_version" {
  default = "1.21"
}

variable "cluster_timeouts" {
  default = {
    create = "120m" # I've seen it exceeding the default "60m" for even a small cluster.
    update = "120m"
    delete = "120m"
  }
}

variable "cluster_service_ipv4_cidr" {
  description = "https://narvar.atlassian.net/wiki/spaces/devops/pages/122028114/VPC+CIDR"
  default     = "172.16.1.0/24"
}

variable "eks_managed_node_group_defaults" {
  type = any
  default = {
    ami_type  = "AL2_x86_64" # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group#ami_type
    disk_size = 10
    key_name  = "devops-master"
  }
}

variable "eks_managed_node_groups" {
  description = "See the sample data structure at https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest#usage"
  type        = any
  default = {
    foundation-ingress-ng = {
      min_size     = 1
      max_size     = 10
      desired_size = 1 # See https://github.com/terraform-aws-modules/terraform-aws-eks/blob/9f85dc8cf5028ed2bab49f495f58e68aa870e7d4/README.md?plain=1#L622-L624

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND" # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group#capacity_type

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

      update_config = { # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group#update_config-configuration-block
        max_unavailable_percentage = 50
      }

      # tags = [
      # # There is no need for us here to explicitly tag with:
      # #   - "k8s.io/cluster-autoscaler/eks-devops" = "owned"
      # #   - "k8s.io/cluster-autoscaler/enabled" = "true"
      # # as wanted by:
      # #   - https://docs.aws.amazon.com/eks/latest/userguide/autoscaling.html#ca-prerequisites
      # # because an EKS "Managed Node Group" automatically tags its corresponding EC2 ASG for us.
      # ]
    }

    devops1-ng = {
      min_size     = 3 # Must be >= number of AZs because of 'kind: PersistentVolume'. See https://stackoverflow.com/questions/51946393/kubernetes-pod-warning-1-nodes-had-volume-node-affinity-conflict#comment125356782_59148459
      max_size     = 10
      desired_size = 3 # See https://github.com/terraform-aws-modules/terraform-aws-eks/blob/9f85dc8cf5028ed2bab49f495f58e68aa870e7d4/README.md?plain=1#L622-L624

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      update_config = {
        max_unavailable_percentage = 50
      }

      # tags = [
      # # See comments above (for previous node group).
      # ]
    }
  }
}
