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
  default = "vpc-f5b9db8c"
}

# variable "private_subnets" {
#   description = "https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/terraform.tfvars#L13"
#   default     = "subnet-93e635ea,subnet-66f64f3c,subnet-256e9c6e"
# }

# variable "public_subnets" {
#   description = "https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/terraform.tfvars#L15"
#   default     = "subnet-f9fc2f80,subnet-266e9c6d,subnet-44ed541e"
# }

# variable "ssl_certificate_arn" {
#   description = "https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/terraform.tfvars#L17"
#   default     = "arn:aws:acm:us-west-2:472882997329:certificate/568f169e-3833-4c3e-a1f3-4660d36bace1"
# }

variable "ssl_certificate_arn_us_east_1" {
  description = "https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/terraform.tfvars#L19"
  default     = "arn:aws:acm:us-east-1:472882997329:certificate/1666da08-047c-4882-bf8b-216ffb07ad52"
}

variable "zone_id" {
  description = "https://github.com/narvar/DevOps/blob/2997edf1415fd3d26efb779d9f9e39e263c20954/terraform/stacks/qa02_uswest2/terraform.tfvars#L21"
  default     = "Z2L4YFFSGDM2VI"
}

# variable "zone_id_internal" {
#   description = "https://github.com/narvar/DevOps/blob/2997edf1415fd3d26efb779d9f9e39e263c20954/terraform/stacks/qa02_uswest2/terraform.tfvars#L23"
#   default     = "Z1WXLHHOPQDEWR"
# }

# variable "bastion_group_id" {
#   description = "https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/terraform.tfvars#L25"
#   default     = "sg-65d6f51a"
# }

# variable "metabase_security_group_id" {
#   description = "https://github.com/narvar/DevOps/blob/2997edf1415fd3d26efb779d9f9e39e263c20954/terraform/stacks/qa02_uswest2/terraform.tfvars#L29"
#   default     = "sg-a99ef3d6"
# }

# variable "qa01_vpc_cidr" {
#   description = "https://github.com/narvar/DevOps/blob/2997edf1415fd3d26efb779d9f9e39e263c20954/terraform/stacks/qa02_uswest2/terraform.tfvars#L41"
#   default     = "10.100.0.0/16"
# }

variable "qa_exception_lambda_role_arn" {
  description = "https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/terraform.tfvars#L49"
  default     = "arn:aws:iam::472882997329:role/exception_lambda"
}

variable "qa_exception_order_ndr_data_push_arn" {
  description = "https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/terraform.tfvars#L51"
  default     = "arn:aws:lambda:us-west-2:472882997329:function:exception-order_ndr_data_push-qa02"
}

variable "qa_exception_callbacks_tracking_push_queue_processor" {
  description = "https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/terraform.tfvars#L53"
  default     = "arn:aws:lambda:us-west-2:472882997329:function:exception-callbacks_tracking-push-queue-processor-qa02"
}

# variable "component_platform_db_password" {
#   description = "https://github.com/narvar/DevOps/blob/2d4823469670b81baecaf57fe64dcfa86cc98f47/terraform/stacks/qa02_uswest2/variables.tf#L83"
# }
