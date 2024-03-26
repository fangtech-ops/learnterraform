# Subsequent (after bootstrap) terraform programs (in various `terraform.tf` and `providers.tf`) will `assume_role` to this role.
module "iam_assumable_role" {
  # https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-assumable-role
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4.10.1"

  create_role          = true
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
