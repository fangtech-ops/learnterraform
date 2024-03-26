# See addition comments in ./15-dns-zone-devops-narvarcorp-net.tf

locals {
  domain_name_qa71_narvarcorp_net = "qa71.narvarcorp.net"
}

module "route53-zone-qa71-narvarcorp-net" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 2.4.0"

  zones = {
    "${local.domain_name_qa71_narvarcorp_net}" = {
      comment = "ManagedBy: terraform"
    }
  }
}

locals {
  zone_id_qa71_narvarcorp_net = module.route53-zone-qa71-narvarcorp-net.route53_zone_zone_id[local.domain_name_qa71_narvarcorp_net]
}

resource "aws_route53_record" "qa71-narvarcorp-net" {
  zone_id = local.zone_id_narvarcorp_net           # Parent zone
  name    = local.domain_name_qa71_narvarcorp_net # Record Name: in this case, it must be the subdomain name
  type    = "NS"
  ttl     = "172800" # Value suggested by https://aws.amazon.com/premiumsupport/knowledge-center/create-subdomain-route-53/

  records = module.route53-zone-qa71-narvarcorp-net.route53_zone_name_servers[local.domain_name_qa71_narvarcorp_net] # Subdomain's name servers
}

output "domain_name_qa71_narvarcorp_net" {
  value = local.domain_name_qa71_narvarcorp_net
}

output "zone_id_qa71_narvarcorp_net" {
  value = local.zone_id_qa71_narvarcorp_net
}
