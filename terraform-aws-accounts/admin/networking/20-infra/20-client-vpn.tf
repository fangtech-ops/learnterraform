# This is the "AWS Client VPN" box in this diagram:
#   - https://aws.amazon.com/blogs/networking-and-content-delivery/using-aws-client-vpn-to-scale-your-work-from-home-capacity/
#     Section "Client VPN to many VPCs"

data "aws_acmpca_certificate_authority" "private-ca-root" {
  # See ../10-bootstrap/README.md for how this private root CA was created earlier.
  arn = "arn:aws:acm-pca:us-west-2:580941417126:certificate-authority/0b4ed7f8-b3bf-4215-92f2-7d0bd3910f1f"
}

locals {
  # These are routes that are *in addition* to jump-vpc's CIDR.
  #
  # While we could have listed the exact CIDR of every spoke VPC (which connects to jump-vpc via Transit Gateway), 
  # that wouldn't be a stable list. The list would change each time we add/delete a spoke VPC.
  #
  # The easiest would have been to add the entire 10.0.0.0/8, but that would give this error:
  #     │ Error: error creating client VPN route "cvpn-endpoint-09de40338642d4993,subnet-05ce3c629de5e4a81,10.0.0.0/8":
  #     |   InvalidParameterValue: Client address pool for this endpoint overlaps with the destination cidr block
  # which means client_cidr_block cannot overlap with destination_cidr_block.
  #
  # So, our CIDRs below is 10.0.0.0/8 minus the CIDR planned for the 'networking' account (including client_cidr_block=10.70.56.0/21).
  # This is a stable list that covers all existing and future AWS VPCs.
  #
  # To restrict which spoke VPCs this VPN can connect to, use:
  #   - Routing table for jump-vpc, i.e., "aws_route" in ./20-transit-gateway.tf
  #   - Security Groups in each spoke VPC
  #
  # [Future Expansion] To restrict traffic based on user's access_group_id (SSO 'group' attribute mapped from G Suite attribute 'Department'):
  #   - https://github.com/narvar/tf-aws-client-vpn/blob/main/README.md
  #   - https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/cvpn-working-rules.html
  #
  # The "Routes per Client VPN endpoint" now exceeds the default quota of 10:
  #   - https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/limits.html
  # The manual procedure to increase the quota is described in ../10-bootstrap/README.md.
  additional_routes = flatten([
    for subnet_id in module.jump-vpc.private_subnets :
    [
      # https://www.davidc.net/sites/default/subnets/subnets.html?network=10.0.0.0&mask=8&division=21.b7d100
      for cidr in [
        "10.0.0.0/10",  # 10.[0-63].*.*
        "10.64.0.0/14", # 10.[64-67].*.*
        "10.68.0.0/15", # 10.[68-69].*.*
        # ............... # 10.70.[0-63].*,  i.e., skip "10.70.0.0/18" planned for the 'networking' account
        "10.70.64.0/18",  # 10.70.[64-127].*
        "10.70.128.0/17", # 10.70.[128-255].*
        "10.71.0.0/16",   # 10.71.*.*
        "10.72.0.0/13",   # 10.[72-79].*.*
        "10.80.0.0/12",   # 10.[80-95].*.*
        "10.96.0.0/11",   # 10.[96-127].*.*
        "10.128.0.0/9",   # 10.[128-255].*.*
      ] :
      {
        destination_cidr_block = cidr
        description            = "Managed by terraform (client-vpn-devops.additional_routes - https://github.com/narvar/terraform-aws-accounts/blob/main/admin/networking/20-infra/20-client-vpn.tf)"
        target_vpc_subnet_id   = subnet_id
      }
    ]
  ])
}

# output "additional_routes" { # For debugging
#   value = local.additional_routes
# }


module "client-vpn-devops" {
  source = "git@github.com:narvar/tf-aws-client-vpn.git?ref=0.0.3" # https://www.terraform.io/language/modules/sources#github
  # source = "../../../../tf-aws-client-vpn"

  # This will become:
  #   - the "Name" column  in https://us-west-2.console.aws.amazon.com/vpc/home?region=us-west-2#ClientVPNEndpoints:sort=clientVpnEndpointId
  #   - the name displayed in https://console.aws.amazon.com/iamv2/home#/identity_providers
  name = "client-vpn-devops"

  vpc_id               = module.jump-vpc.vpc_id
  associated_subnets   = module.jump-vpc.private_subnets
  split_tunnel_enabled = true

  # [BUG]:  For some reason, "enabled" doesn't result in a workable portal.
  #         If "enabled", after we go to the web portal (self_service_portal_url) and enter the SSO credential, the browser will give
  #         an error for failing to connect to 127.0.0.1:35001.
  self_service_portal = "disabled"

  # https://narvar.atlassian.net/wiki/spaces/devops/pages/122028114/VPC+CIDR
  # Rule of thumb (https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/scaling-considerations.html):
  #   - Two IPs per client connection. Therefore, 2,048 IPs support roughly 1,000 concurrent user sessions.
  client_cidr_block = "10.70.56.0/21" # 2,048 IPs: 10.70.[56-63].*

  server_certificate_arn = aws_acm_certificate.client-vpn-devops-server-cert.arn

  # This XML is downloaded from G Suite.
  # When configuring G Suite (manually), take note of the following very tricky procedure in fiddling with 'http://127.0.0.1:35001':
  #   - https://benincosa.com/?p=3787
  #
  # G Suite's original default downloaded file name was `GoogleIDPMetadata.xml`.
  # This XML doesn't contain secrets, therefore safe to be checked into Git repo.
  saml_metadata_document = file("./20-client-vpn-GoogleIDPMetadata.xml")

  authorization_rules = [
    {
      name = "Foundation-Eng"
      # access_group_id      = "..." # See README inside the module.
      authorize_all_groups = true
      description          = "Managed by terraform (client-vpn-devops.authorization_rules)"

      # This needs to be considered in conjunction with split_tunnel_enabled.
      # For example, if split_tunnel_enabled=false and target_network_cidr=10.0.0.0/8,
      # then we'd cut our own laptop off from internet when this VPN is in effect.
      target_network_cidr = "10.0.0.0/8"
    }
  ]

  additional_routes = local.additional_routes
}

output "self_service_portal_url" {
  value = module.client-vpn-devops.self_service_portal_url
}

output "aws_iam_saml_provider_arn" {
  value = module.client-vpn-devops.aws_iam_saml_provider_arn
}


# ................................. SSL Cert ..........................................................
# We cannot use the following AWS module for creating a *private* cert:
#   - https://registry.terraform.io/modules/terraform-aws-modules/acm/aws/3.2.0 (latest as of Nov 2021)
# because it is hard coded to create a *public* cert, i.e., a cert signed by a CA chain that
# ends in a well-known public root CA such as Digicert.
# 
# Navar has a public cert `*.narvar.com` in the ACM of the old Prod account `533313119160`.
# That existing cert would have been good except:
#   - It is in a different account than our current account, but AWS doesn't have the feature for cross-account sharing of cert.
#   - If we import that cert (it is not an ACM-generated cert, but an imported cert to begin with) to our current account,
#     then we'd have to worry about manually renewing it every year in this account as well as in the old Prod account.
#     That's repetitive manual work and is easy to forget.
#
# Besides, we don't need a *public* server cert. Almost all the literature (AWS docs, 3rd-party blogs, open source
# Terraform Registry modules, etc.) implies (although not explicitly asserted -- I think very few people actually understand it) 
# that AWS Client VPN needs a *public* server cert. That is not true. In fact, a closer scrutiny of the AWS official tutorial
# reveals that *private* server cert can do the job (although the tutorial's wording is vague):
#   - https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/cvpn-getting-started.html#cvpn-getting-started-certs
#   - https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/client-authentication.html#awsui-tabs-0-linux%2Fmacos-panel
#
# The server's CA cert (either a root CA or an intermediate CA) is automatically embedded 
# in the client-side config file (default file name `downloaded-client-config.ovpn` which can be downloaded from AWS Admin Console.)
# This is analogous to importing a (private) CA into a browser or a Java keystore. Therefore, whether the CA is
# public or private is irrelevant because the VPN client software is configured to accept any server cert that is issued by that CA.


# Create a private server cert (for AWS Client VPN endpoint) which is issued by an existing private root CA.
# Even though our CA is private, we still need to use "aws_acm_certificate" instead of "aws_acmpca_certificate"
# despite the latter name "acmpca" stands for "ACM *Private* CA". The reason is explained here:
#   - https://github.com/hashicorp/terraform-provider-aws/issues/5550#issuecomment-413565363
resource "aws_acm_certificate" "client-vpn-devops-server-cert" {

  # This value doesn't matter. 
  # It is a meaningless placeholder to satisfy X.509 format, having nothing to do with DNS or HTTP.
  # The VPN client software doesn't look up this DNS domain_name at runtime, and the VPN connection isn't HTTP(s).
  domain_name = "narvar.local"

  # Although the resource to be created is "aws_acm_certificate" (rather than "aws_acmpca_certificate" as explained above), 
  # the CA is still the *private* CA as shown here.
  certificate_authority_arn = data.aws_acmpca_certificate_authority.private-ca-root.id
}
