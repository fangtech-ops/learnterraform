# This is the "VPC A" box in this diagram:
#   - https://aws.amazon.com/blogs/networking-and-content-delivery/using-aws-client-vpn-to-scale-your-work-from-home-capacity/
#     Section "Client VPN to many VPCs"

module "jump-vpc" {
  source  = "terraform-aws-modules/vpc/aws" # https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws
  version = "~> 3.11.3"

  name = "jump-vpc"
  azs  = ["${var.aws_region}a", "${var.aws_region}b"]
  cidr = "10.70.0.0/24" # 256 IPs, https://narvar.atlassian.net/wiki/spaces/devops/pages/122028114/VPC+CIDR

  # Create at least 2 subnets so that AWS Client VPN endpoint can attach to both/all subnets for high availability (HA).
  # Our subnets don't need to be public because the public AWS Client VPN service endpoint forwards the IP packets
  # to a private link (ENI) inside our private subnet(s).
  #
  # AWS Client VPN endpoint (supposedly) consumes 1 ENI per subnet. This is documented in various AWS blogs.
  #
  # What isn't documented is it sometimes unpredicably consumes 2 or more ENIs (I've seen up to 3). This tends to happen
  # more often when we allocate only one subnet. It isn't a problem, just so not to be surprised when looking at the ENIs.
  private_subnets = [
    "10.70.0.0/27",  # 10.70.0.[0-31]    (32 IPs)
    "10.70.0.32/27", # 10.70.0.[32-63]   (32 IPs)
  ]

  # Unused space: 10.70.0.64-10.70.0.256 (192 IPs)

  enable_dns_hostnames = true

  tags = { test = "Atlantis dummy test" }
}

output "jump-vpc-vpc_id" {
  value = module.jump-vpc.vpc_id
}

output "jump-vpc-private_subnets" {
  value = module.jump-vpc.private_subnets
}
