#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

module "vpc1" {
  source  = "terraform-aws-modules/vpc/aws"
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
