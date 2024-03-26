# Here we create the (empty) AWS resource in AWS Secrets Manager.
# We do NOT populate this resource with any name:value pairs of secret strings (e.g., passwords, tokens, private keys).
# The population of such secret strings are performed by hand (e.g., via AWS Admin Console).


# Troubleshooting:
#   Problem: If this secret is deleted ('tf destroy -target ...') then attempted to be recreated right away, we'd get:
#               │ Error: error creating Secrets Manager Secret:
#               | InvalidRequestException: You can't create this secret because a secret with this name is already scheduled for deletion.
#   Solution: https://aws.amazon.com/premiumsupport/knowledge-center/delete-secrets-manager-secret/
#

resource "aws_secretsmanager_secret" "fluent-bit" {
  # Prefix every secret name with the team's name so that the full ARN looks like:
  #   "arn:aws:secretsmanager:us-west-2:106628749228:secret:foundation-team/artifactory/kubernetes.io/dockerconfigjson-wKyoZg"
  # That allows prefix-based IAM policies like this:
  #   - https://docs.aws.amazon.com/secretsmanager/latest/userguide/auth-and-access_examples.html#auth-and-access_examples_wildcard
  # i.e., it allows us potentially (maybe in the near future) to construct an IAM policy such that
  # each team has access only to the team's own secrets but not to other team's secrets.
  # The slash ('/') otherwise has no significance to AWS Secrets Manager. It's just our own naming convention to
  # facilitate (future) wildcard match when constructing the IAM policy.
  #
  name        = "foundation-team/fluent-bit" # Must match https://github.com/narvar/flux-infra/blob/13f83ae93960b831d2f343760375006d3977e65e/resources/external-secrets/foundation-team/fluent-bit/google-service-credentials-json/external-secrets.yaml#L22
  description = "Used by https://github.com/narvar/flux-infra/tree/master/resources/external-secrets/foundation-team/fluent-bit"
}

resource "aws_secretsmanager_secret_policy" "fluent-bit" {
  secret_arn          = aws_secretsmanager_secret.fluent-bit.arn
  block_public_policy = true

  # For the IAM role AWSReservedSSO_narvar-read-all-access, it already has a blanket read privilege for all secrets granted by:
  #   - https://github.com/narvar/terraform-aws-control-tower/blob/master/40-sso/10-permission-sets.tf
  # And, the IAM role AWSReservedSSO_AWSAdministratorAccess has '*:*' privilege to everything -- including Secrets Manager.
  # So, we don't need to worry about the above roles in this inline policy below. Here we only need to grant to additional roles.
  # The Kubernetes plugin 'external-secrets' needs to derive 'kind: Secret' from this Secrets Manager secret.
  # This is a resource policy (i.e., attached to the current resource, not attached to an IAM user/role);
  # so, the "Resource": "*" part effectively refers to only this (current) secret rather than all secrets.
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
