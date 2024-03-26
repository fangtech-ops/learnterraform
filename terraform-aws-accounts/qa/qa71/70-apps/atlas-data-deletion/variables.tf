#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

variable "aws_region" {
  default = "us-west-2"
}

variable "narvar_terraform_role_arn" {
  default = "arn:aws:iam::472882997329:role/NarvarTerraformRole"
}

variable "terraform_remote_state_eks_config" {
  description = "This block is copied verbatim from ../30-eks1/terraform.tf"
  default = {
    bucket         = "tf-8b0c5430-f097-54b8-8e22-2d6eb0c4e0c8"
    key            = "qa/qa71/30-eks1/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-8b0c5430-f097-54b8-8e22-2d6eb0c4e0c8-state-lock"
    role_arn       = "arn:aws:iam::472882997329:role/NarvarTerraformRole"
  }
}
