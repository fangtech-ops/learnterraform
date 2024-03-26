#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################


# .....................................................
resource "aws_secretsmanager_secret" "linkerd-ca-crt" {
  name        = "foundation-team/linkerd-ca-crt"
  description =<<EOT
    Used by https://github.com/narvar/flux-infra/tree/master/resources/external-secrets/foundation-team/linkerd
    and manually populated with procedure at https://linkerd.io/2.11/tasks/generate-certificates/#generating-the-certificates-with-step
  EOT
}

resource "aws_secretsmanager_secret_policy" "linkerd-ca-crt" {
  secret_arn          = aws_secretsmanager_secret.linkerd-ca-crt.arn
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

# .....................................................

resource "aws_secretsmanager_secret" "linkerd-ca-key" {
  name        = "foundation-team/linkerd-ca-key"
  description =<<EOT
    Used by https://github.com/narvar/flux-infra/tree/master/resources/external-secrets/foundation-team/linkerd
    and manually populated with procedure at https://linkerd.io/2.11/tasks/generate-certificates/#generating-the-certificates-with-step
  EOT
}

resource "aws_secretsmanager_secret_policy" "linkerd-ca-key" {
  secret_arn          = aws_secretsmanager_secret.linkerd-ca-key.arn
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

# .....................................................

resource "aws_secretsmanager_secret" "linkerd-issuer-crt" {
  name        = "foundation-team/linkerd-issuer-crt"
  description =<<EOT
    Used by https://github.com/narvar/flux-infra/tree/master/resources/external-secrets/foundation-team/linkerd
    and manually populated with procedure at https://linkerd.io/2.11/tasks/generate-certificates/#generating-the-certificates-with-step
  EOT
}

resource "aws_secretsmanager_secret_policy" "linkerd-issuer-crt" {
  secret_arn          = aws_secretsmanager_secret.linkerd-issuer-crt.arn
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

# .....................................................

resource "aws_secretsmanager_secret" "linkerd-issuer-key" {
  name        = "foundation-team/linkerd-issuer-key"
  description =<<EOT
    Used by https://github.com/narvar/flux-infra/tree/master/resources/external-secrets/foundation-team/linkerd
    and manually populated with procedure at https://linkerd.io/2.11/tasks/generate-certificates/#generating-the-certificates-with-step
  EOT
}

resource "aws_secretsmanager_secret_policy" "linkerd-issuer-key" {
  secret_arn          = aws_secretsmanager_secret.linkerd-issuer-key.arn
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
