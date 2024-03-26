#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

variable "aws_region" { default = "us-west-2" }

variable "narvar_terraform_role_arn" { default = "arn:aws:iam::580941417126:role/NarvarTerraformRole" }

variable "amazon_side_asn" {
  description = "https://narvar.atlassian.net/wiki/spaces/devops/pages/122028114/VPC+CIDR"
  default     = "64540"
}

variable "enable_aws_ebs_encryption_by_default" {
  default = true
}
