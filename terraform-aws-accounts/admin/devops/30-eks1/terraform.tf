terraform {
  required_version = "~> 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.73"
    }
  }

  # This EKS cluster is in its own terraform.tfstate. The S3 path is named after the filesystem dir name ('30-eks1')
  # If we need a 2nd EKS cluster in the future, create a parallel filesystem dir (e.g., ./30-eks2/*) and the
  # corresponding S3 path (e.g., key = "admin/devops/30-eks2/terraform.tfstate").
  backend "s3" {
    bucket         = "tf-6d5612ed-1736-5d4e-a92f-7fe7df219d0d"
    key            = "admin/devops/30-eks1/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-6d5612ed-1736-5d4e-a92f-7fe7df219d0d-state-lock"
    role_arn       = "arn:aws:iam::106628749228:role/NarvarTerraformRole" # i.e., var.narvar_terraform_role_arn
  }
}
