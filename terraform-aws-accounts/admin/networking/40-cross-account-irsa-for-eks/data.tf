data "terraform_remote_state" "eks-devops" { # https://www.terraform.io/docs/language/settings/backends/s3.html#data-source-configuration
  backend = "s3"
  config = { # This block is copied verbatim from admin/devops/30-eks1/terraform.tf
    bucket         = "tf-6d5612ed-1736-5d4e-a92f-7fe7df219d0d"
    key            = "admin/devops/30-eks1/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-6d5612ed-1736-5d4e-a92f-7fe7df219d0d-state-lock"
    role_arn       = "arn:aws:iam::106628749228:role/NarvarTerraformRole"
  }
}

data "terraform_remote_state" "eks-dev71" {
  backend = "s3"
  config = { # This block is copied verbatim from dev/dev71/30-eks1/terraform.tf
    bucket         = "tf-9f991585-b198-5a16-8dd0-aad0100f4e64"
    key            = "dev/dev71/30-eks1/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-9f991585-b198-5a16-8dd0-aad0100f4e64-state-lock"
    role_arn       = "arn:aws:iam::342812538696:role/NarvarTerraformRole"
  }
}

data "terraform_remote_state" "eks-qa71" {
  backend = "s3"
  config = { # This block is copied verbatim from qa/qa71/30-eks1/terraform.tf
    bucket         = "tf-8b0c5430-f097-54b8-8e22-2d6eb0c4e0c8"
    key            = "qa/qa71/30-eks1/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-8b0c5430-f097-54b8-8e22-2d6eb0c4e0c8-state-lock"
    role_arn       = "arn:aws:iam::472882997329:role/NarvarTerraformRole"
  }
}

data "terraform_remote_state" "eks-st71" {
  backend = "s3"
  config = { # This block is copied verbatim from st/st71/30-eks1/terraform.tf
    bucket         = "tf-8b0c5430-f097-54b8-8e22-2d6eb0c4e0c8"
    key            = "st/st71/30-eks1/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-8b0c5430-f097-54b8-8e22-2d6eb0c4e0c8-state-lock"
    role_arn       = "arn:aws:iam::472882997329:role/NarvarTerraformRole"
  }
}

data "terraform_remote_state" "infra" { # https://www.terraform.io/docs/language/settings/backends/s3.html#data-source-configuration
  backend = "s3"
  config = { # This block is copied verbatim from ../20-infra/terraform.tf
    bucket         = "tf-2539da7a-5bf5-5850-b4ae-bb295e291bf6"
    key            = "admin/networking/20-infra/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-2539da7a-5bf5-5850-b4ae-bb295e291bf6-state-lock"
    role_arn       = "arn:aws:iam::580941417126:role/NarvarTerraformRole" # i.e., var.narvar_terraform_role_arn
  }
}
