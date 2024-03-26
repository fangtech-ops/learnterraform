#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4.10.1"

  create_role          = false
  role_name            = "NarvarTerraformRole"
  role_requires_mfa    = "false"
  max_session_duration = 7200

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]

  trusted_role_arns = var.trusted_role_arns
}

output "iam_role_arn" {
  value = module.iam_assumable_role.iam_role_arn
}
