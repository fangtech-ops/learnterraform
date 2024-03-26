#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

variable "aws_region" {
  default = "us-west-2"
}

variable "narvar_terraform_role_arn" {
  default = "arn:aws:iam::342812538696:role/NarvarTerraformRole"
}

variable "vpc1-name" {
  default = "vpc-dev71"
}

variable "vpc1-cidr" {
  description = "10.191.[0-127].* (32,768 IPs), see https://narvar.atlassian.net/wiki/spaces/devops/pages/122028114/VPC+CIDR"
  default     = "10.191.0.0/17"
}

variable "vpc1-private_subnets" {
  default = [
    "10.191.0.0/19",  # 10.191.[0-31].*   (8,192 IPs)
    "10.191.32.0/19", # 10.191.[32-63].*  (8,192 IPs)
    "10.191.64.0/19", # 10.191.[64-95].*  (8,192 IPs)
  ]
}

# Unused space between private and public subnets:
#   10.191.96.0-10.191.124.255  (7424 IPs = 4096 + 2048 + 1024 + 256)

variable "vpc1-public_subnets" {
  default = [
    "10.191.127.0/24", # 10.191.127.*     (256 IPs)
    "10.191.126.0/24", # 10.191.126.*     (256 IPs)
    "10.191.125.0/24", # 10.191.125.*     (256 IPs)
  ]
}

variable "jump-vpc-cidr" {
  default = "10.70.0.0/24"
}

variable "enable_aws_ebs_encryption_by_default" {
  default = true
}
