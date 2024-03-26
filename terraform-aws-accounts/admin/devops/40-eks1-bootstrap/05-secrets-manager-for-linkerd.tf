#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################


# We are creating 4 ARNs (4 separate AWS resources). Each AWS resource contains a single, one-piece, free-formatted string.
# This is different from the strategy we use for, say, fluent bit, where we have a single ARN and,
# within that single AWS resource, we use multiple key/value pairs to represent multiple secret strings.
#
# Each of our string here is the verbatim content (with embedded/actual line breaks rather than the character sequence "\n")
# of a *.crt or *.key file as described in this procedure:
#   - https://linkerd.io/2.11/tasks/generate-certificates/#generating-the-certificates-with-step
#
# The secret content is NOT any of the following format:
#   - It is NOT in key/value pair format (a.k.a. JSON).
#   - It does NOT contain escape sequence such as "\n". Our string contains embedded line breaks rather than the character sequence "\n".
#
# The JSON format won't work because it doesn't handle embedded line breaks. See:
#   - https://forums.aws.amazon.com/thread.jspa?threadID=316996
#
# If we use the character sequence "\n" (as opposed to embedded line breaks), we'd run into
# this next problem:
#   - The 'valuesFrom:' field in Flux 'kind: HelmRelease' takes the string literally rather than
#     substituting the character sequence "\n" to a line break.
# So, it would result in an ill-formatted PEM content.
#
# Putting it together, we cannot use JSON format in AWS Secrets Manager in this case.


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
