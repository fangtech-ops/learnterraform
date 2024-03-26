# # Analogous to 20-narvar-irsa-role-for-external-dns-policy-content.tf

# # https://cert-manager.io/docs/configuration/acme/dns01/route53/
# data "aws_iam_policy_document" "cert-manager" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "route53:GetChange",
#     ]
#     resources = ["arn:aws:route53:::change/*"]
#   }

#   statement {
#     effect = "Allow"
#     actions = [
#       "route53:ChangeResourceRecordSets",
#       "route53:ListResourceRecordSets",
#     ]
#     resources = [
#       "arn:aws:route53:::hostedzone/${data.terraform_remote_state.infra.outputs.zone_id_devops_narvarcorp_net}",
#       # "arn:aws:route53:::hostedzone/${local.private_hosted_zone_id}",
#     ]
#   }

#   statement {
#     effect = "Allow"
#     actions = [
#       "route53:ListHostedZonesByName",
#     ]
#     resources = ["*"]
#   }
# }
