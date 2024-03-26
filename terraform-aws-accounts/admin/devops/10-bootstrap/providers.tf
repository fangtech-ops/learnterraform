provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn = var.narvar_bootstrap_role_arn
  }

  default_tags {
    tags = {
      ManagedBy = "terraform"
    }
  }
}
