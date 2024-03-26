# Our naming convention and coding pattern achieve these goals:
#   - Terraform resource names (e.g., module name "vpc1" which appears in terraform.tfstate file) are generically named.
#     This makes terraform source code identical across AWS accounts.
#   - AWS resource names (e.g., something like "vpc-devops" as shown in AWS Admin Console) are/can be meaningful.
#     This is the 'name' attribute in the following module. Its value comes from var.vpc1_name.
# This is very similar to the strategy we use for EKS (see ./30-infra/eks.tf).
module "vpc1" {
  source  = "terraform-aws-modules/vpc/aws" # https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws
  version = "~> 3.11.3"

  name = var.vpc1-name
  azs  = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]

  cidr            = var.vpc1-cidr
  private_subnets = var.vpc1-private_subnets
  public_subnets  = var.vpc1-public_subnets

  enable_dns_hostnames = true
  enable_nat_gateway = true

  tags = { test = "Atlantis dummy test" }
}

output "vpc1-vpc_id" {
  value = module.vpc1.vpc_id
}

output "vpc1-private_subnets" {
  value = module.vpc1.private_subnets
}
