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

variable "jump-vpc-cidr" {
  default = "10.70.0.0/24"
}

# VPC ID
variable "vpc_id" {
  default = "vpc-d1e72db6"
}

# Public Route Tables
variable "public_route_table_ids" {
  default = ["rtb-1eea7379"]
}

# Private Route Tables
variable "private_route_table_ids" {
  default = ["rtb-acea73cb","rtb-abea73cc","rtb-adea73ca"]
}

# # Public Subnets
# variable "public_subnets" {
#   default = ["subnet-b4ada2c2","subnet-80ae5ae7","subnet-c759279f"]
# }

# Private Subnets
variable "private_subnets" {
  default = ["subnet-b7ada2c1","subnet-81ae5ae6","subnet-f85927a0"]
}

#qa71 vpc cidr
variable "qa71-vpc-cidr" {
  default = "10.181.0.0/17"
}
