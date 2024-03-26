#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

variable "aws_region" {
  default = "us-west-2"
}

variable "narvar_terraform_role_arn" {
  default = "arn:aws:iam::472882997329:role/NarvarTerraformRole"
}

variable "vpc_id" {
  description = "https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/terraform.tfvars#L3"
  default = "vpc-f5b9db8c"
}

# variable "domain" {
#   description = "https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/terraform.tfvars#L9"
#   default = "narvar.qa"
# }

variable "private_subnets" {
  description = "https://github.com/narvar/DevOps/blob/2997edf1415fd3d26efb779d9f9e39e263c20954/terraform/stacks/qa02_uswest2/terraform.tfvars#L13"
  default = "subnet-93e635ea,subnet-66f64f3c,subnet-256e9c6e"
}

# variable "public_subnets" {
#   description = "https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/terraform.tfvars#L15"
#   default = "subnet-f9fc2f80,subnet-266e9c6d,subnet-44ed541e"
# }

# variable "ssl_certificate_arn" {
#   description = "https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/terraform.tfvars#L17"
#   default = "arn:aws:acm:us-west-2:472882997329:certificate/568f169e-3833-4c3e-a1f3-4660d36bace1"
# }

# variable "ssl_certificate_arn_us_east_1" {
#   description = "https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/terraform.tfvars#L19"
#   default = "arn:aws:acm:us-east-1:472882997329:certificate/1666da08-047c-4882-bf8b-216ffb07ad52"
# }

# variable "zone_id" {
#   description = "https://github.com/narvar/DevOps/blob/2997edf1415fd3d26efb779d9f9e39e263c20954/terraform/stacks/qa02_uswest2/terraform.tfvars#L21"
#   default = "Z2L4YFFSGDM2VI"
# }

variable "zone_id_internal" {
  description = "https://github.com/narvar/DevOps/blob/2997edf1415fd3d26efb779d9f9e39e263c20954/terraform/stacks/qa02_uswest2/terraform.tfvars#L23"
  default = "Z1WXLHHOPQDEWR"
}

# variable "bastion_group_id" {
#   description = "https://github.com/narvar/DevOps/blob/2997edf1415fd3d26efb779d9f9e39e263c20954/terraform/stacks/qa02_uswest2/terraform.tfvars#L25"
#   default = "sg-65d6f51a"
# }

# variable "qa_notification_time_service_arn" {
#   description = "https://github.com/narvar/DevOps/blob/2997edf1415fd3d26efb779d9f9e39e263c20954/terraform/stacks/qa02_uswest2/terraform.tfvars#L33"
#   default = "arn:aws:lambda:us-west-2:472882997329:function:comms_lambda_notification_time_service-qa02"
# }

# variable "alb_security_policy" {
#   description = "https://github.com/narvar/DevOps/blob/2997edf1415fd3d26efb779d9f9e39e263c20954/terraform/stacks/qa02_uswest2/terraform.tfvars#L37"
#   default = "ELBSecurityPolicy-TLS-1-2-2017-01"
# }

# variable "qa01_vpc_cidr" {
#   description = "https://github.com/narvar/DevOps/blob/2997edf1415fd3d26efb779d9f9e39e263c20954/terraform/stacks/qa02_uswest2/terraform.tfvars#L41"
#   default = "10.100.0.0/16"
# }

# variable "st01_vpc_cidr" {
#   description = "https://github.com/narvar/DevOps/blob/2997edf1415fd3d26efb779d9f9e39e263c20954/terraform/stacks/qa02_uswest2/terraform.tfvars#L43"
#   default = "10.120.0.0/16"
# }

# variable "qa_returns_rules_arn" {
#   description = "https://github.com/narvar/DevOps/blob/2997edf1415fd3d26efb779d9f9e39e263c20954/terraform/stacks/qa02_uswest2/terraform.tfvars#L45"
#   default = "arn:aws:lambda:us-west-2:472882997329:function:returns_rules_manager-qa02"
# }

