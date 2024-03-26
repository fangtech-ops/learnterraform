# See Also: Comments in ./05-secrets-manager-for-fluent-bit.tf

resource "aws_secretsmanager_secret" "artifactory" {
  name        = "foundation-team/artifactory"
  description = "Used by https://github.com/narvar/flux-infra/tree/master/resources/external-secrets/foundation-team/artifactory"
}

resource "aws_secretsmanager_secret_policy" "artifactory" {
  secret_arn          = aws_secretsmanager_secret.artifactory.arn
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
