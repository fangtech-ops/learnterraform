variable "aws_region" {
  default = "us-west-2"
}

variable "narvar_bootstrap_role_arn" {
  # At this moment, we cannot use 'NarvarTerraformRole' because it hasn't been created yet.
  default = "arn:aws:iam::106628749228:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_AWSAdministratorAccess_93060f8c67728fb7" # current account
}

variable "environment" {
  default = "admin"
}

variable "project_name" {
  default = "devops-infra"
}

variable "trusted_role_arns" {
  type = list(string)
  default = [
    "arn:aws:iam::106628749228:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_AWSAdministratorAccess_93060f8c67728fb7", # 'devops' account
    "arn:aws:iam::106628749228:role/narvar-irsa-role-for-atlantis",                                                                   # Allow Atlantis from eks-devops
  ]
}
