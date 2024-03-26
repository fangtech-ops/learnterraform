#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

variable "aws_region" {
  default = "us-west-2"
}

# variable "narvar_bootstrap_role_arn" {
#   default = "arn:aws:iam::342812538696:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_AWSAdministratorAccess_c07bf92e3e331fc3" # current account
# }

variable "environment" {
  default = "qa"
}

variable "project_name" {
  default = "qa71-infra"
}

variable "trusted_role_arns" {
  type = list(string)
  default = [
    "arn:aws:iam::106628749228:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_AWSAdministratorAccess_93060f8c67728fb7", # central 'devops' account
    "arn:aws:iam::106628749228:role/narvar-irsa-role-for-atlantis",                                                                   # Allow Atlantis from central eks-devops
    "arn:aws:iam::472882997329:user/rong.chen@narvar.com",
    "arn:aws:iam::472882997329:user/steve.liang@narvar.com",
    "arn:aws:iam::472882997329:user/vishal.vivek@narvar.com",
    "arn:aws:iam::472882997329:user/ankur.jain@narvar.com",
    "arn:aws:iam::472882997329:user/Vincent.Yin@narvar.com",
    "arn:aws:iam::472882997329:user/hoan.mac@narvar.com",
    "arn:aws:iam::472882997329:user/amar.sattaur@narvar.com",
  ]
}
