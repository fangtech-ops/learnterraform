#################################################################################################################
# For inline comments that apply to all accounts' terraform, see the *.tf files in 'devops' account (OU='admin').
# All common comments belong there.
# Only the comments that are unique to this particular account should be in this file.
#################################################################################################################

locals {
  tgw_id = "tgw-030a7b8804d642bb3"
}

module "jump-tgw-spoke-attachment" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 2.5.0"

  name        = "jump-tgw-spoke-attachment"
  description = "This tgw is shared from (owned by) the hub jump-tgw"

  create_tgw = false

  share_tgw                             = false
  enable_auto_accept_shared_attachments = true

  ram_resource_share_arn = "arn:aws:ram:us-west-2:580941417126:resource-share/ea24eddb-4b29-4392-8cef-fe715cbfc7d4"

  vpc_attachments = {
    vpc1 = {
      tgw_id     = local.tgw_id
      vpc_id     = module.vpc1.vpc_id
      subnet_ids = module.vpc1.private_subnets
    },
  }
}

resource "aws_route" "from-vpc1-public-subnets-to-jump-vpc" {
  count = length(module.vpc1.public_route_table_ids)

  route_table_id         = module.vpc1.public_route_table_ids[count.index]
  destination_cidr_block = var.jump-vpc-cidr

  transit_gateway_id = local.tgw_id
}

resource "aws_route" "from-vpc1-private-subnets-to-jump-vpc" {
  count = length(module.vpc1.private_route_table_ids)

  route_table_id         = module.vpc1.private_route_table_ids[count.index]
  destination_cidr_block = var.jump-vpc-cidr
  transit_gateway_id     = local.tgw_id
}
