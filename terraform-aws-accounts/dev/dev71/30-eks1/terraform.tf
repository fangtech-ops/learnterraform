terraform {
  required_version = "~> 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.73"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.6"
    }
  }

  backend "s3" {
    bucket         = "tf-9f991585-b198-5a16-8dd0-aad0100f4e64"
    key            = "dev/dev71/30-eks1/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-9f991585-b198-5a16-8dd0-aad0100f4e64-state-lock"
    role_arn       = "arn:aws:iam::342812538696:role/NarvarTerraformRole"
  }
}
