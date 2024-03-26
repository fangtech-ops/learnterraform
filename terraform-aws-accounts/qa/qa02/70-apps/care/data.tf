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

# output "vpc_name" {
#   value = local.vpc_name
# }

# output "vpc_shortname" {
#   value = local.vpc_shortname
# }

# # https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/redshift.tf#L22
# data "aws_security_group" "eks_worker" {
#   vpc_id = var.vpc_id
#   name = "eks_worker-${local.vpc_name}"
# }

# # https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/api_gateway.tf#L2-L5
# data "aws_api_gateway_rest_api" "api_gateway" {
#   name = "api-${local.vpc_shortname}"
# }

# # https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/api_gateway.tf#L13-L17
# data "aws_api_gateway_resource" "v1" {
#   rest_api_id = data.aws_api_gateway_rest_api.api_gateway.id
#   path        = "/api/v1"
# }

# # https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/returns_front.tf#L32
# data "aws_security_group" "returns-front" {
#   vpc_id = var.vpc_id
#   name = "returns_front-${local.vpc_name}"
# }

# # https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/returns_back.tf#L1
# data "aws_security_group" "returns-back" {
#   vpc_id = var.vpc_id
#   name = "returns_back-${local.vpc_name}"
# }

# # https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/healthcheck.tf#L1
# data "aws_security_group" "healthcheck-alb" {
#   vpc_id = var.vpc_id
#   name = "healthcheck-${local.vpc_name}-alb"
# }

# # https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/api.tf#L1
# data "aws_security_group" "api-alb" {
#   vpc_id = var.vpc_id
#   name = "api-${local.vpc_name}-alb"
# }

# # https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/quartz_trigger.tf#L25
# data "aws_security_group" "quartz_trigger" {
#   vpc_id = var.vpc_id
#   name   = "quartz_trigger-${local.vpc_name}"
# }

# # This SG is from qa01 -- it's a cross-stack reference.
# # Both qa01 and qa02 belong to the same (old) AWS account. That's why it's possible to reference another stack's SG ID.
# # In the future, Jenkins probably should be migrated to the new 'devops' AWS account. Each stack should be completely
# # insulated from each other -- there shouldn't be cross-stack references.
# #
# # https://github.com/narvar/DevOps/blob/2997edf1415fd3d26efb779d9f9e39e263c20954/terraform/stacks/qa02_uswest2/returns_front.tf#L53
# # https://github.com/narvar/DevOps/blob/2997edf1415fd3d26efb779d9f9e39e263c20954/terraform/stacks/qa01_uswest2/jenkins.tf#L184
# data "aws_security_group" "jenkins_aws_security_group" {
#   vpc_id = "vpc-d1e72db6" # qa01's VPC (not qa02)
#   name   = "jenkins-qa01_uswest2"
# }
