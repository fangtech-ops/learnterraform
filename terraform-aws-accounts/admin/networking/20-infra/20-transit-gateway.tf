# This is the "AWS Transit Gateway" box in this diagram:
#   - https://aws.amazon.com/blogs/networking-and-content-delivery/using-aws-client-vpn-to-scale-your-work-from-home-capacity/
#     Section "Client VPN to many VPCs"
#
# The configs consist of 2 sides:
#   - The config of this TGW -- done in this terraform file.
#   - The config of the attachments in spoke VPCs (done by terraform in each spoke account's Git repo/folder)
#
# For now, both sides of the configs point to the same TGW routing table. To prevent a spoke VPC A from connecting to another spoke VPC B,
# we do the following:
#   - Don't enter B's CIDR into A's subnets' routing tables (not to be confused with TGW routing table).
#   - And/or, use Security Groups in B to disallow the A's IP addresses.
#   - See Also: https://aws.amazon.com/premiumsupport/knowledge-center/transit-gateway-connect-vpcs-from-vpn/
#
# In the future (if the need arises), to achieve or enhance the same goal, we can change our design to use 
# a separate TGW routing table per TGW Attachment (to spoke VPC) as explained here:
#   - https://aws.amazon.com/blogs/networking-and-content-delivery/building-a-global-network-using-aws-transit-gateway-inter-region-peering/
# One advantage of this (future) alternate design is that the control of routing lies with the 'networking' account (which owns the TGW)
# rather than the spoke accounts (which owns the TGW Attachments to the spoke VPCs). 
# One disadvantage is that there'd be more AWS resources to keep track of, and we need some deep understanding of 
# the module "terraform-aws-modules/transit-gateway/aws" in order to supply the input params properly (the module's online docs don't help.)

module "jump-tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws" # https://registry.terraform.io/modules/terraform-aws-modules/transit-gateway/aws
  version = "~> 2.5.0"

  name            = "jump-tgw"
  description     = "Connecting the jump-vpc (AWS Client VPN) with application VPCs in various AWS accounts (e.g., prod71)"
  amazon_side_asn = var.amazon_side_asn

  # This flag, when set, creates a 'resource share' in AWS RAM. The terraform addresses are:
  #   - module.jump-tgw.aws_ram_resource_association.this[0]
  #   - module.jump-tgw.aws_ram_resource_share.this[0]
  # Therefore, we don't need to separately create stuff in RAM outside of this module.
  share_tgw = true # Default: true

  enable_auto_accept_shared_attachments = true # Only meaningful when share_tgw = true.
  
  # Allowing external principals
  ram_allow_external_principals = true
  # Share this TGW with selective OU ARNs or Account IDs.
  # Only meaningful when share_tgw = true.
  # The terraform addresses are like these:
  #    module.jump-tgw.aws_ram_principal_association.this[0]
  #    module.jump-tgw.aws_ram_principal_association.this[1]
  #    module.jump-tgw.aws_ram_principal_association.this[2]
  #    ...
  # Each spoke account uses its own terraform (in the spoke account's Git repo/folder)
  # to attach this shared TGW to a spoke VPC.
  ram_principals = [
    "arn:aws:organizations::905426566754:ou/o-4cy5b8yhs9/ou-n74l-cr3wvkrg", # OU: admin (needed by the account 'devops', etc.)
    "arn:aws:organizations::905426566754:ou/o-4cy5b8yhs9/ou-n74l-2ltis1lc", # OU: lab
    "arn:aws:organizations::905426566754:ou/o-4cy5b8yhs9/ou-n74l-j6fylfwk", # OU: dev
    "arn:aws:organizations::905426566754:ou/o-4cy5b8yhs9/ou-n74l-zxy5xjwd", # OU: qa
    "arn:aws:organizations::905426566754:ou/o-4cy5b8yhs9/ou-n74l-zuray5ul", # OU: st
    "arn:aws:organizations::905426566754:ou/o-4cy5b8yhs9/ou-n74l-q74ukfz0", # OU: prod
    "472882997329", #QA account
  ]

  # A collection of VPCs within this account. So far, we only have 1 such VPC.
  # Don't list spoke accounts' VPCs here.
  vpc_attachments = {
    jump-vpc = {
      vpc_id     = module.jump-vpc.vpc_id
      subnet_ids = module.jump-vpc.private_subnets

      # Don't supply 'tgw_routes' below. It is for populating a new, non-default routing table.
      # But this feature has numerous Github open issues as of Nov 2021:
      #     - https://github.com/terraform-aws-modules/terraform-aws-transit-gateway/issues
      # We don't need this feature anyway. The default routing table (automatically created and populated by AWS)
      # already satisfies our needs.
      #
      # tgw_routes = [{...}, {...}, {...},]
    },
  }

  # Even without the above 'tgw_routes', this module still creates an (empty) non-default routing table.
  # Such a table isn't associated with any VPC attachment and is therefore useless. But the fact
  # that it is lying around and visible in AWS Admin Console is pretty confusing. It can be considered a bug:
  #     - https://github.com/terraform-aws-modules/terraform-aws-transit-gateway/issues/58
  # Adding to the confusion, this superfluous routing table has the same name with the (good & active) AWS-generated default routing table.
  # In order to distinguish between the two, I'm tagging it with the following note.
  tgw_route_table_tags = {
    NarvarNote = "This is a superfluous routing table created by terraform-aws-modules/transit-gateway/aws. It's not in effect."
  }
}

output "jump-tgw-ec2_transit_gateway_id" {
  value = module.jump-tgw.ec2_transit_gateway_id
}

output "jump-tgw-ram_resource_share_id" {
  value = module.jump-tgw.ram_resource_share_id
}

# With the confusions explained above, let's print out which route table is actually in effect.
output "jump-tgw-ec2_transit_gateway_association_default_route_table_id" {
  value = module.jump-tgw.ec2_transit_gateway_association_default_route_table_id
}

# I dont' understand why this output var doesn't agree with input var:
#     - https://github.com/terraform-aws-modules/terraform-aws-transit-gateway/issues/60
#
# output "jump-tgw-ec2_transit_gateway_route_table_default_association_route_table" {
#   value = module.jump-tgw.ec2_transit_gateway_route_table_default_association_route_table
# }


# ....................... Adding custom routes to jump-vpc: one route per spoke VPC ............................
# See:
#   - https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/116 - This shows the heart of the trick.
#   - https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/588 - An elaborate example.

resource "aws_route" "from-jump-vpc-private-subnets-to-dev71-vpc1" {
  count = length(module.jump-vpc.private_route_table_ids)

  route_table_id         = module.jump-vpc.private_route_table_ids[count.index]
  destination_cidr_block = "10.191.0.0/17"
  transit_gateway_id     = module.jump-tgw.ec2_transit_gateway_id
}

resource "aws_route" "from-jump-vpc-private-subnets-to-qa71-vpc1" {
  count = length(module.jump-vpc.private_route_table_ids)

  route_table_id         = module.jump-vpc.private_route_table_ids[count.index]
  destination_cidr_block = "10.181.0.0/17"
  transit_gateway_id     = module.jump-tgw.ec2_transit_gateway_id
}

resource "aws_route" "from-jump-vpc-private-subnets-to-qa01-vpc1" {
  count = length(module.jump-vpc.private_route_table_ids)

  route_table_id         = module.jump-vpc.private_route_table_ids[count.index]
  destination_cidr_block = "10.100.0.0/16"
  transit_gateway_id     = module.jump-tgw.ec2_transit_gateway_id
}

resource "aws_route" "from-jump-vpc-private-subnets-to-st71-vpc1" {
  count = length(module.jump-vpc.private_route_table_ids)

  route_table_id         = module.jump-vpc.private_route_table_ids[count.index]
  destination_cidr_block = "10.171.0.0/17"
  transit_gateway_id     = module.jump-tgw.ec2_transit_gateway_id
}

resource "aws_route" "from-jump-vpc-private-subnets-to-devops-vpc1" {
  count = length(module.jump-vpc.private_route_table_ids)

  route_table_id         = module.jump-vpc.private_route_table_ids[count.index]
  destination_cidr_block = "10.70.64.0/21"
  transit_gateway_id     = module.jump-tgw.ec2_transit_gateway_id
}

output "jump-vpc-private_route_table_ids" { # Debug
  value = module.jump-vpc.private_route_table_ids
}
