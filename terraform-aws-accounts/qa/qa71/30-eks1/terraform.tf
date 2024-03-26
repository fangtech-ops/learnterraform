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
    bucket         = "tf-8b0c5430-f097-54b8-8e22-2d6eb0c4e0c8"
    key            = "qa/qa71/30-eks1/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-8b0c5430-f097-54b8-8e22-2d6eb0c4e0c8-state-lock"
    role_arn       = "arn:aws:iam::472882997329:role/NarvarTerraformRole"
  }
}
