locals {
  service_account_namespace_application = "core-services"
  service_account_name_application      = "service-${local.application_name}"
  irsa_role_name_application            = "irsa-role-${local.cluster_name}-${local.application_name}"
}

module "irsa-role-atlas-data-deletion" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 4.10.1"

  create_role = true
  role_name   = local.irsa_role_name_application

  provider_url                  = local.cluster_oidc_issuer_url
  role_policy_arns              = [aws_iam_policy.irsa-policy-atlas-data-deletion.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.service_account_namespace_application}:${local.service_account_name_application}"]
}

resource "aws_iam_policy" "irsa-policy-atlas-data-deletion" {
  name        = local.irsa_role_name_application
  path        = "/"
  description = "Allow atlas-data-deletion pods to access dynamodb and s3"
  policy      = data.aws_iam_policy_document.irsa-policy-atlas-data-deletion.json
}

data "aws_iam_policy_document" "irsa-policy-atlas-data-deletion" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      "arn:aws:s3:::narvar-data-qa01",
      "arn:aws:s3:::narvar-data-qa01/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
      "dynamodb:CreateTable",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:UpdateItem",
    ]
    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${local.account_id}:table/order_catalog",
      "arn:aws:dynamodb:${var.aws_region}:${local.account_id}:table/order_catalog/*",
      "arn:aws:dynamodb:${var.aws_region}:${local.account_id}:table/item_catalog",
      "arn:aws:dynamodb:${var.aws_region}:${local.account_id}:table/item_catalog/*",
      "arn:aws:dynamodb:${var.aws_region}:${local.account_id}:table/shipment_catalog",
      "arn:aws:dynamodb:${var.aws_region}:${local.account_id}:table/shipment_catalog/*",
      "arn:aws:dynamodb:${var.aws_region}:${local.account_id}:table/customer_catalog",
      "arn:aws:dynamodb:${var.aws_region}:${local.account_id}:table/customer_catalog/*",
      "arn:aws:dynamodb:${var.aws_region}:${local.account_id}:table/pickup_catalog",
      "arn:aws:dynamodb:${var.aws_region}:${local.account_id}:table/pickup_catalog/*",
      "arn:aws:dynamodb:${var.aws_region}:${local.account_id}:table/return_catalog",
      "arn:aws:dynamodb:${var.aws_region}:${local.account_id}:table/return_catalog/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:ListTables",
    ]
    resources = ["*"]
  }
}
