#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

resource "aws_secretsmanager_secret" "fluent-bit" {
  name        = "foundation-team/fluent-bit"
  description = "Used by https://github.com/narvar/flux-infra/tree/master/resources/external-secrets/foundation-team/fluent-bit"
}

resource "aws_secretsmanager_secret_policy" "fluent-bit" {
  secret_arn          = aws_secretsmanager_secret.fluent-bit.arn
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
