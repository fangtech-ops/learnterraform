# To facilitate drift detection on 20-transit-gateway-spoke-attachment.tf between different environments (via diff.sh),
# we move these extra routes to this separate file.

variable "qa01-vpc-cidr" {
  default = "10.100.0.0/16"
}

resource "aws_route" "from-vpc1-public-subnets-to-qa01-vpc" {
  count = length(module.vpc1.public_route_table_ids)

  route_table_id         = module.vpc1.public_route_table_ids[count.index]
  destination_cidr_block = var.qa01-vpc-cidr

  transit_gateway_id = local.tgw_id
}

resource "aws_route" "from-vpc1-private-subnets-to-qa01-vpc" {
  count = length(module.vpc1.private_route_table_ids)

  route_table_id         = module.vpc1.private_route_table_ids[count.index]
  destination_cidr_block = var.qa01-vpc-cidr
  transit_gateway_id     = local.tgw_id
}
