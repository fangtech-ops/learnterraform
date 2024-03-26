# https://www.terraform.io/docs/language/settings/index.html#terraform-block-syntax
# Excerpt:
#     "Within a terraform block, only constant [i.e., hard-coded] values can be used"
terraform {
  required_version = "~> 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.73" # https://registry.terraform.io/providers/hashicorp/aws
    }
  }
}
