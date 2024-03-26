# See Also: Comments in ./05-secrets-manager-for-fluent-bit.tf

# ................................................................................................
# After this is created by terraform, go to AWS Admin Console and manually populate this secret like this:
#   - key: github_secret; value: the cleartext Github webhook secret of Atlantis
#   - key: github_token;  value: the cleartext Gitbub token of the Github user account (e.g., token for the user ID 'ravrangitops')
#
# To (manually) obtain the cleartext of those existing secrets (or how/where those secrets were originally created), see:
#   - https://github.com/narvar/terraform-aws-accounts/blob/main/admin/devops/40-eks1-bootstrap/README.md#1-how-to-terraform-apply-in-this-folder-for-the-first-time

resource "aws_secretsmanager_secret" "atlantis-vcs-secret-for-github-webhook" {
  name        = "foundation-team/atlantis-vcs-secret-for-github-webhook" # Must match https://github.com/narvar/flux-infra/blob/a7fe7c31a3148a7d24c96244535c397b5660ccd0/resources/external-secrets/foundation-team/atlantis/atlantis-vcs-secret-for-github-webhook/external-secrets.yaml#L22
  description = "Used by https://github.com/narvar/flux-infra/tree/master/resources/external-secrets/foundation-team/atlantis/atlantis-vcs-secret-for-github-webhook"

  tags = { test = "Atlantis dummy test" }
}

resource "aws_secretsmanager_secret_policy" "atlantis-vcs-secret-for-github-webhook" {
  secret_arn          = aws_secretsmanager_secret.atlantis-vcs-secret-for-github-webhook.arn
  block_public_policy = true

  policy = <<EOT
    {
        "Version": "2012-10-17",
        "Statement": {
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "${module.narvar-irsa-role-for-external-secrets.iam_role_arn}"
                ]
            },
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": "*"
        }
    }
  EOT
}

# ................................................................................................
# After this is created by terraform, go to AWS Admin Console and manually populate this secret like this:
# Don't use the key/value pair format (JSON). Use the Plain format and enter the following as a whole string
# (without surrounding it with curly braces, but with embedded linebreaks).
# The ghp_xxxxxxx part is the github_token used in the previous (above) secret.
#
#     [url "https://ghp_xxxxxxx@github.com"]
#       insteadOf = ssh://git@github.com

resource "aws_secretsmanager_secret" "atlantis-gitconfig-for-fetching-terraform-private-modules" {
  name        = "foundation-team/atlantis-gitconfig-for-fetching-terraform-private-modules" # Must match https://github.com/narvar/flux-infra/blob/a7fe7c31a3148a7d24c96244535c397b5660ccd0/resources/external-secrets/foundation-team/atlantis/atlantis-gitconfig-for-fetching-terraform-private-modules/external-secrets.yaml#L23
  description = "Used by https://github.com/narvar/flux-infra/tree/master/resources/external-secrets/foundation-team/atlantis/atlantis-gitconfig-for-fetching-terraform-private-modules"
}

resource "aws_secretsmanager_secret_policy" "atlantis-gitconfig-for-fetching-terraform-private-modules" {
  secret_arn          = aws_secretsmanager_secret.atlantis-gitconfig-for-fetching-terraform-private-modules.arn
  block_public_policy = true

  policy = <<EOT
    {
        "Version": "2012-10-17",
        "Statement": {
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "${module.narvar-irsa-role-for-external-secrets.iam_role_arn}"
                ]
            },
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": "*"
        }
    }
  EOT
}


# ................................................................................................
# After this is created by terraform, go to AWS Admin Console and manually populate this secret like this:
#   - key: qa02_component_platform_db_password; value: the cleartext password obtained from LastPass item 'Component Platform Database'
#   - key: st02_component_platform_db_password; value: ...
#   - ...

resource "aws_secretsmanager_secret" "atlantis-tf-var-database-passwords" {
  name        = "foundation-team/atlantis-tf-var-database-passwords" # Must match https://github.com/narvar/flux-infra/blob/afbce15541f5a60f0346a09d97be226b51e39f73/resources/external-secrets/foundation-team/atlantis/atlantis-tf-var-database-passwords/external-secrets.yaml#L18
  description = "Used by https://github.com/narvar/flux-infra/tree/master/resources/external-secrets/foundation-team/atlantis/atlantis-tf-var-database-passwords"
}

resource "aws_secretsmanager_secret_policy" "atlantis-tf-var-database-passwords" {
  secret_arn          = aws_secretsmanager_secret.atlantis-tf-var-database-passwords.arn
  block_public_policy = true

  policy = <<EOT
    {
        "Version": "2012-10-17",
        "Statement": {
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "${module.narvar-irsa-role-for-external-secrets.iam_role_arn}"
                ]
            },
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": "*"
        }
    }
  EOT
}
