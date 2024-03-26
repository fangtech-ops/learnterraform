variable "aws_region" { default = "us-west-2" }

variable "narvar_terraform_role_arn" {
  default = "arn:aws:iam::106628749228:role/NarvarTerraformRole"
}

variable "terraform_remote_state_eks_config" {
  description = "This block is copied verbatim from ../30-eks1/terraform.tf"
  default = {
    bucket         = "tf-6d5612ed-1736-5d4e-a92f-7fe7df219d0d"
    key            = "admin/devops/30-eks1/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-6d5612ed-1736-5d4e-a92f-7fe7df219d0d-state-lock"
    role_arn       = "arn:aws:iam::106628749228:role/NarvarTerraformRole"
  }
}

variable "terraform_remote_state_networking_infra_config" {
  description = "This block is copied verbatim from /admin/networking/20-infra/terraform.tf"
  default = {
    bucket         = "tf-2539da7a-5bf5-5850-b4ae-bb295e291bf6"
    key            = "admin/networking/20-infra/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-2539da7a-5bf5-5850-b4ae-bb295e291bf6-state-lock"
    role_arn       = "arn:aws:iam::580941417126:role/NarvarTerraformRole"
  }
}

variable "terraform_remote_state_networking_irsa_config" {
  description = "This block is copied verbatim from /admin/networking/40-cross-account-irsa-for-eks/terraform.tf"
  default = {
    bucket         = "tf-2539da7a-5bf5-5850-b4ae-bb295e291bf6"
    key            = "admin/networking/40-cross-account-irsa-for-eks/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-2539da7a-5bf5-5850-b4ae-bb295e291bf6-state-lock"
    role_arn       = "arn:aws:iam::580941417126:role/NarvarTerraformRole"
  }
}


variable "github_user" {
  description = "Github user ID. https://fluxcd.io/docs/get-started/#export-your-credentials"
  default     = "ravrangitops"
}

variable "github_token" {
  description = "Github Personal Access Token for the 'github_user'. https://fluxcd.io/docs/get-started/#export-your-credentials"
}

# variable "github_atlantis_webhook_secret" {
#   description = "Github repo's webhook secret for Atlantis. https://www.runatlantis.io/docs/configuring-webhooks.html#github-github-enterprise"
# }

variable "terraform_configuraton_file" {
  default = "config-maps/aws/admin/devops/terraform-generated/kustomization.yaml"
}

variable "aws_auth_file" {
  default = "config-maps/aws/admin/devops/aws-auth/aws-auth.yaml"
}

variable "github_repository_file_cm_commit_message" {
  default = "Managed by https://github.com/narvar/terraform-aws-accounts/blob/main/admin/devops/40-eks1-bootstrap/30-flux-config-map.tf"
}

variable "flux_bootstrap_params" {
  default = "narvar flux-infra master ./clusters/aws/admin/devops"
}

variable "aws_auth_append" {
  default = <<EOT
    - rolearn: arn:aws:iam::106628749228:role/AWSReservedSSO_AWSAdministratorAccess_93060f8c67728fb7
      username: narvar-admin
      groups:
        - system:masters
    - rolearn: arn:aws:iam::106628749228:role/AWSReservedSSO_narvar-read-all-access_582c891a89abcac8
      username: narvar-read-all
      groups:
        - narvar-read-all-group
  EOT
}
