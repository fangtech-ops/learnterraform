data "aws_vpc" "main" {
  id = var.vpc_id
}

locals {
  # https://github.com/narvar/DevOps/blob/2997edf1415fd3d26efb779d9f9e39e263c20954/terraform/stacks/qa02_uswest2/terraform.tfvars#L5
  vpc_name = replace(data.aws_vpc.main.tags["Name"], "/^vpc-/", "") # Strip leading substring 'vpc-'. Sample transformation: "vpc-qa02_uswest2" => "qa02_uswest2"

  # https://github.com/narvar/DevOps/blob/2997edf1415fd3d26efb779d9f9e39e263c20954/terraform/stacks/qa02_uswest2/terraform.tfvars#L7
  vpc_shortname = replace(local.vpc_name, "/_.*/", "") # Strip the first (greedy match) underscore '_' and thereafter. Sample transformation: "qa02_uswest2" => "qa02"

  # https://github.com/narvar/DevOps/blob/2997edf1415fd3d26efb779d9f9e39e263c20954/terraform/stacks/qa02_uswest2/terraform.tfvars#L39
  vpc_cidr = data.aws_vpc.main.cidr_block
}

# # https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/redshift.tf#L22
# data "aws_security_group" "eks_worker" {
#   vpc_id = var.vpc_id
#   name   = "eks_worker-${local.vpc_name}"
# }

# # https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/assist.tf#L32
# data "aws_security_group" "assist" {
#   vpc_id = var.vpc_id
#   name   = "assist-${local.vpc_name}"
# }

# # https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/api.tf#L1
# data "aws_security_group" "api-alb" {
#   vpc_id = var.vpc_id
#   name   = "api-${local.vpc_name}-alb"
# }

# # .........................................
# data "aws_security_group" "comms_lambda" {
#   vpc_id = var.vpc_id
#   name   = "comms_lambda-${local.vpc_name}-alb"
# }

# data "aws_security_group" "consumer_notify_prefs" {
#   vpc_id = var.vpc_id
#   name   = "consumer_notify_prefs-${local.vpc_name}"
# }

# data "aws_security_group" "content_api" {
#   vpc_id = var.vpc_id
#   name   = "content_api-${local.vpc_name}"
# }

# data "aws_security_group" "edd-checkout-api" {
#   vpc_id = var.vpc_id
#   name   = "edd_checkout_api-${local.vpc_name}"
# }

# data "aws_security_group" "orders-api" {
#   vpc_id = var.vpc_id
#   name   = "orders_api-${local.vpc_name}"
# }

# data "aws_security_group" "quartz_trigger" {
#   vpc_id = var.vpc_id
#   name   = "quartz_trigger-${local.vpc_name}"
# }

# data "aws_security_group" "returns-back" {
#   vpc_id = var.vpc_id
#   name   = "returns_back-${local.vpc_name}"
# }

# data "aws_security_group" "returns-front" {
#   vpc_id = var.vpc_id
#   name   = "returns_front-${local.vpc_name}"
# }

# data "aws_security_group" "return-service-apis" {
#   vpc_id = var.vpc_id
#   name   = "return-service-apis-${local.vpc_name}"
# }

# data "aws_security_group" "shopify" {
#   vpc_id = var.vpc_id
#   name   = "shopify-${local.vpc_name}"
# }

# data "aws_security_group" "sleep_service" {
#   vpc_id = var.vpc_id
#   name   = "sleep-service-${local.vpc_name}"
# }

# data "aws_security_group" "template_processor_internal" {
#   vpc_id = var.vpc_id
#   name   = "template_processor_internal-${local.vpc_name}"
# }

# data "aws_security_group" "toran" {
#   vpc_id = var.vpc_id
#   name   = "toran-${local.vpc_name}"
# }

# data "aws_security_group" "tracking-api" {
#   vpc_id = var.vpc_id
#   name   = "tracking_api-${local.vpc_name}"
# }

# data "aws_security_group" "tracking-back" {
#   vpc_id = var.vpc_id
#   name   = "tracking_back-${local.vpc_name}"
# }

