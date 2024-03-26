#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

terraform {
  required_version = "~> 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.73"
    }
  }

  backend "s3" {
    bucket         = "tf-2539da7a-5bf5-5850-b4ae-bb295e291bf6"
    key            = "admin/networking/40-cross-account-irsa-for-eks/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-2539da7a-5bf5-5850-b4ae-bb295e291bf6-state-lock"
    role_arn       = "arn:aws:iam::580941417126:role/NarvarTerraformRole" # i.e., var.narvar_terraform_role_arn
  }
}
