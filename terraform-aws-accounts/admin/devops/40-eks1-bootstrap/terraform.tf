terraform {
  required_version = "~> 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.73"
    }

    # https://registry.terraform.io/providers/integrations/github
    github = {
      source  = "integrations/github"
      version = "~> 4.19"
    }

    # https://registry.terraform.io/providers/hashicorp/local
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
  }

  # This bootstrap step of EKS is in its own state so that the original creation of EKS cluster (../30-eks1/*)
  # doesn't need any (manually obtained) secrets as input parameters (for installing Flux, Atlantis, etc.)
  # Installation of Flux, Atlantis, etc., are done in this folder where terraform input vars (e.g., var.githubtoken)
  # need to be assigned with externally/manually obtained secrets.
  backend "s3" {
    bucket         = "tf-6d5612ed-1736-5d4e-a92f-7fe7df219d0d"
    key            = "admin/devops/40-eks1-bootstrap/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-6d5612ed-1736-5d4e-a92f-7fe7df219d0d-state-lock"
    role_arn       = "arn:aws:iam::106628749228:role/NarvarTerraformRole" # i.e., var.narvar_terraform_role_arn
  }
}
