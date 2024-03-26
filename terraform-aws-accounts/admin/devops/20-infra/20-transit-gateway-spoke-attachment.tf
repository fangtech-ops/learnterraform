locals {
  tgw_id = "tgw-030a7b8804d642bb3" # The TGW (already) created in the 'networking' account.
}

# Sample code:
#   - https://github.com/terraform-aws-modules/terraform-aws-transit-gateway/blob/master/examples/multi-account/main.tf
#
# The input params to this module don't cause it to create a new TGW.
# Rather, they cause the same (existing) 'jump-tgw' (in the 'networking' account) to attach to this spoke VPC.
# Specifically, the only terraform address created under this module will be:
#   - 'module.jump-tgw-spoke-attachment.aws_ec2_transit_gateway_vpc_attachment.this["vpc1"]'
# Corollary:
#   - There isn't a separate amazon_side_asn input param to this call. The ASN is whatever it was that already belonged to the existing TGW.
module "jump-tgw-spoke-attachment" {
  source  = "terraform-aws-modules/transit-gateway/aws" # https://registry.terraform.io/modules/terraform-aws-modules/transit-gateway/aws
  version = "~> 2.5.0"

  name        = "jump-tgw-spoke-attachment"
  description = "This tgw is shared from (owned by) the hub jump-tgw"

  # We are not creating a new TGW. We're adding a new attachment to the existing TGW.
  create_tgw = false

  # Set to 'false' to suppress the creation of aws_ram_resource_share_accepter (i.e., RAM invitation) because we've
  # already configured the root AWS Organization to allow automatic sharing:
  #   - https://github.com/narvar/terraform-aws-control-tower/tree/master/10-bootstrap#32-aws-admin-console--resource-access-manager-enable-sharing-with-aws-organizations
  # Otherwise, we'd get this error:
  #      │ Error: No RAM Resource Share (arn:aws:ram:us-west-2:580941417126:resource-share/ea24eddb-4b29-4392-8cef-fe715cbfc7d4) invitation found
  #      │
  #      │ NOTE: If both AWS accounts are in the same AWS Organization and RAM Sharing with AWS Organizations is enabled, this resource is not necessary
  #      │
  #      │   with module.jump-tgw-spoke-attachment.aws_ram_resource_share_accepter.this[0],
  #      │   on .terraform/modules/jump-tgw-spoke-attachment/main.tf line 169, in resource "aws_ram_resource_share_accepter" "this":
  #      │  169: resource "aws_ram_resource_share_accepter" "this" {
  share_tgw                             = false
  enable_auto_accept_shared_attachments = true

  # This ARN was created earlier when we ran the terraform for the 'networking' account to create the original TGW -- in which share_tgw = true.
  ram_resource_share_arn = "arn:aws:ram:us-west-2:580941417126:resource-share/ea24eddb-4b29-4392-8cef-fe715cbfc7d4"

  vpc_attachments = {
    vpc1 = {
      tgw_id     = local.tgw_id
      vpc_id     = module.vpc1.vpc_id
      subnet_ids = module.vpc1.private_subnets
    },
  }
}


# ..................................... Adding custom routes to VPC ............................................
# See the inline comments in 'networking' account's terraform (20-transit-gateway-jump-tgw-hub.tf) for additional tips.

resource "aws_route" "from-vpc1-public-subnets-to-jump-vpc" {
  count = length(module.vpc1.public_route_table_ids)

  route_table_id         = module.vpc1.public_route_table_ids[count.index]
  destination_cidr_block = var.jump-vpc-cidr

  # Cannot use 'module.jump-tgw-spoke-attachment.ec2_transit_gateway_id' because we'd get this error:
  #
  #     aws_route.from-vpc1-public-subnets-to-jump-vpc: Creating...
  #     │ Error: error creating Route: route target attribute not specified
  #
  # Reason: The module is written such that, when create_tgw = false, the above output var will be an empty string.
  # See:
  #   - https://github.com/terraform-aws-modules/terraform-aws-transit-gateway/blob/b784a21a07ac558d1279395b105a21734846195d/main.tf#L34
  #   - https://github.com/terraform-aws-modules/terraform-aws-transit-gateway/blob/b784a21a07ac558d1279395b105a21734846195d/outputs.tf#L14
  transit_gateway_id = local.tgw_id
}

resource "aws_route" "from-vpc1-private-subnets-to-jump-vpc" {
  count = length(module.vpc1.private_route_table_ids)

  route_table_id         = module.vpc1.private_route_table_ids[count.index]
  destination_cidr_block = var.jump-vpc-cidr
  transit_gateway_id     = local.tgw_id
}
