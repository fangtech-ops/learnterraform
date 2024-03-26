terraform {
  required_version = "~> 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.73"
    }
  }

  backend "s3" {
    bucket         = "tf-6d5612ed-1736-5d4e-a92f-7fe7df219d0d"
    key            = "admin/devops/20-infra/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-6d5612ed-1736-5d4e-a92f-7fe7df219d0d-state-lock"
    role_arn       = "arn:aws:iam::106628749228:role/NarvarTerraformRole"
  }
}
