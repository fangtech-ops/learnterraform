variable "aws_region" {
  default = "us-west-2"
}

variable "narvar_terraform_role_arn" {
  default = "arn:aws:iam::106628749228:role/NarvarTerraformRole"
}

variable "vpc1-name" {
  default = "vpc-devops"
}

variable "vpc1-cidr" {
  description = "10.70.[64-71].* (2,048 IPs), see https://narvar.atlassian.net/wiki/spaces/devops/pages/122028114/VPC+CIDR"
  default     = "10.70.64.0/21"
}

variable "vpc1-private_subnets" {
  description = "Allocating from low to high within the VPC CIDR, see https://narvar.atlassian.net/wiki/spaces/devops/pages/122028114/VPC+CIDR"
  default = [
    "10.70.64.0/23", # 10.70.[64-65].*      (512 IPs)
    "10.70.66.0/23", # 10.70.[66-67].*      (512 IPs)
    "10.70.68.0/23", # 10.70.[68-69].*      (512 IPs)
  ]
}

# Unused space between private and public subnets:
#   10.70.70.0-10.70.71.63  (320 IPs)

variable "vpc1-public_subnets" {
  description = "Allocating from high to low within the VPC CIDR, see https://narvar.atlassian.net/wiki/spaces/devops/pages/122028114/VPC+CIDR"
  default = [
    "10.70.71.192/26", # 10.70.71.[192-255] (64 IPs)
    "10.70.71.128/26", # 10.70.71.[128-191] (64 IPs)
    "10.70.71.64/26",  #  10.70.71.[64-127]  (64 IPs)
  ]
}

variable "jump-vpc-cidr" {
  description = "CIDR for the existing jump-vpc"
  default     = "10.70.0.0/24"
}

variable "enable_aws_ebs_encryption_by_default" {
  default = true
}
