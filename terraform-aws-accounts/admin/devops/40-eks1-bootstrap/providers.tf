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
