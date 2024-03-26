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
    key            = "admin/networking/20-infra/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-2539da7a-5bf5-5850-b4ae-bb295e291bf6-state-lock"
    role_arn       = "arn:aws:iam::580941417126:role/NarvarTerraformRole" # i.e., var.narvar_terraform_role_arn
  }
}
