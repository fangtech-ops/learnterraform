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

variable "vpc_id" {
  default = "vpc-f5b9db8c"
}

variable "private_subnets" {
  description = "https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/terraform.tfvars#L13"
  default     = "subnet-93e635ea,subnet-66f64f3c,subnet-256e9c6e"
}

variable "public_subnets" {
  description = "https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/terraform.tfvars#L15"
  default     = "subnet-f9fc2f80,subnet-266e9c6d,subnet-44ed541e"
}

variable "qa01_vpc_cidr" {
  description = "https://github.com/narvar/DevOps/blob/2997edf1415fd3d26efb779d9f9e39e263c20954/terraform/stacks/qa02_uswest2/terraform.tfvars#L41"
  default     = "10.100.0.0/16"
}
