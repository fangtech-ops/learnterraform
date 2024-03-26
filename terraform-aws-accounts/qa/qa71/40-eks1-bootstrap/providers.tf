#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = var.narvar_terraform_role_arn
  }
  default_tags {
    tags = {
      ManagedBy = "terraform"
    }
  }
}

provider "github" {
  token = var.github_token
  owner = "narvar"
}
