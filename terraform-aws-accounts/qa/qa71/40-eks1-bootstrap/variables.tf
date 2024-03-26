#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

variable "aws_region" { default = "us-west-2" }

variable "narvar_terraform_role_arn" {
  default = "arn:aws:iam::472882997329:role/NarvarTerraformRole"
}

variable "terraform_remote_state_eks_config" {
  description = "This block is copied verbatim from ../30-eks1/terraform.tf"
  default = {
    bucket         = "tf-8b0c5430-f097-54b8-8e22-2d6eb0c4e0c8"
    key            = "qa/qa71/30-eks1/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-8b0c5430-f097-54b8-8e22-2d6eb0c4e0c8-state-lock"
    role_arn       = "arn:aws:iam::472882997329:role/NarvarTerraformRole"
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
  default = "config-maps/aws/qa/qa71/terraform-generated/kustomization.yaml"
}

variable "aws_auth_file" {
  default = "config-maps/aws/qa/qa71/aws-auth/aws-auth.yaml"
}

variable "github_repository_file_cm_commit_message" {
  default = "Managed by https://github.com/narvar/terraform-aws-accounts/blob/main/qa/qa71/40-eks1-bootstrap/30-flux-config-map.tf"
}

variable "flux_bootstrap_params" {
  default = "narvar flux-infra master ./clusters/aws/qa/qa71"
}

variable "aws_auth_append" {
  default = <<EOT
    - rolearn: arn:aws:iam::472882997329:role/NarvarTerraformRole
      username: narvar-admin
      groups:
        - system:masters
    - rolearn: arn:aws:iam::472882997329:role/eks-admin-role
      username: narvar-eks-admin
      groups:
        - system:masters

  mapUsers: |
    - userarn: arn:aws:iam::472882997329:user/rong.chen@narvar.com
      username: rong.chen@narvar.com
      groups:
        - system:masters
    - userarn: arn:aws:iam::472882997329:user/steve.liang@narvar.com
      username: steve.liang@narvar.com
      groups:
        - system:masters
    - userarn: arn:aws:iam::472882997329:user/vishal.vivek@narvar.com
      username: vishal.vivek@narvar.com
      groups:
        - system:masters
    - userarn: arn:aws:iam::472882997329:user/ankur.jain@narvar.com
      username: ankur.jain@narvar.com
      groups:
        - system:masters
    - userarn: arn:aws:iam::472882997329:user/Vincent.Yin@narvar.com
      username: vincent.yin@narvar.com
      groups:
        - system:masters
    - userarn: arn:aws:iam::472882997329:user/hoan.mac@narvar.com
      username: hoan.mac@narvar.com
      groups:
        - system:masters
    - userarn: arn:aws:iam::472882997329:user/amar.sattaur@narvar.com
      username: amar.sattaur@narvar.com
      groups:
        - system:masters
    - userarn: arn:aws:iam::472882997329:user/karl.haslinger@narvar.com
      username: karl.haslinger@narvar.com
      groups:
        - system:masters
    - userarn: arn:aws:iam::472882997329:user/sander.wang@narvar.com
      username: sander.wang@narvar.com
      groups:
        - system:masters
    - userarn: arn:aws:iam::472882997329:user/Charles.Lee@narvar.com
      username: Charles.Lee@narvar.com
      groups:
        - system:masters

EOT
}
