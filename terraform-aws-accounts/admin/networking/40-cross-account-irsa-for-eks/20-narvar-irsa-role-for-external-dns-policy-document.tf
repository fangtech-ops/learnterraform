# # This is the common JSON content used by (analogous to copy-and-pasted to) all external-dns IAM policies (one per EKS cluster).
# # Note: This is in the form of a terraform 'data source' rather than a terraform 'resource'.
# data "aws_iam_policy_document" "external-dns" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "route53:ChangeResourceRecordSets",
#     ]

#     resources = [
#       "arn:aws:route53:::hostedzone/${data.terraform_remote_state.infra.outputs.zone_id_devops_narvarcorp_net}",
#       # "arn:aws:route53:::hostedzone/${local.private_hosted_zone_id}",
#     ]
#   }

#   statement {
#     effect = "Allow"

#     actions = [
#       "route53:ListHostedZones",
#       "route53:ListResourceRecordSets",
#     ]

#     resources = ["*"]
#   }
# }
