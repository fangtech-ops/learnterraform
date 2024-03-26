locals {
  domain_name_devops_narvarcorp_net = "devops.narvarcorp.net"
}

# This creates a subdomain zone. This by itself doesn't make the subdomain "visible" publically, i.e.,
# we cannot resovle DNS names in this zone via "nslookup" or "dig". For that, we have to hook it
# up to the parent zone (the next module call). I wish someone has packaged these 2 module calls into a single call.
module "route53-zone-devops-narvarcorp-net" {
  source  = "terraform-aws-modules/route53/aws//modules/zones" # https://registry.terraform.io/modules/terraform-aws-modules/route53/aws
  version = "~> 2.4.0"

  zones = {
    "${local.domain_name_devops_narvarcorp_net}" = {
      comment = "ManagedBy: terraform"
    }
  }
}

locals {
  zone_id_devops_narvarcorp_net = module.route53-zone-devops-narvarcorp-net.route53_zone_zone_id[local.domain_name_devops_narvarcorp_net]
}

# This hooks up a (public) subdomain zone (e.g., devops.narvarcorp.net) to its (public) parent domain, similar to these explanations:
#   - https://aws.amazon.com/premiumsupport/knowledge-center/create-subdomain-route-53/
#   - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone#public-subdomain-zone
#
# Whether a zone (for a subdomain such as devops.narvarcorp.net) is public or private is a design pattern rather than an explicit attribute.
#
# A public zone has its name servers listed as NS records in the parent zone. The parent zone's name servers are in turn listed
# in the grandparent's NS records, and so on, until the chain stops at a (public) domain registrar (GoDaddy, Route 53, etc.)
#
# A private zone, on the other hand, doesn't have such a chain ending up in a public domain registrar. 
# Also, for Route 53, private zones require at least one VPC association at all times.
#
# Cannot call this module:
#    https://registry.terraform.io/modules/terraform-aws-modules/route53/aws/latest/submodules/zones
# because when we pass the param:
#    records = module.route53-zone-devops-narvarcorp-net.route53_zone_name_servers
# we'd get this:
#     │ Error: Invalid for_each argument
#     │
#     │   on .terraform/modules/route53-records-narvarcorp-net/modules/records/main.tf line 32, in resource "aws_route53_record" "this":
#     │   32:   for_each = var.create && (var.zone_id != null || var.zone_name != null) ? local.recordsets : tomap({})
#     │     |
#     │     │ local.recordsets will be known only after apply
#     │     │ ...
#     │
#     │ The "for_each" value depends on resource attributes that cannot be determined until apply, so Terraform cannot predict
#     │ how many instances will be created. To work around this, use the -target argument to first apply only the resources 
#     │ that the for_each depends on.
#
# module "route53-records-narvarcorp-net" {
#   source    = "terraform-aws-modules/route53/aws//modules/records" # https://registry.terraform.io/modules/terraform-aws-modules/route53/aws
#   version   = "~> 2.4.0"
#   zone_name = local.domain_name_narvarcorp_net # Parent zone
#   records = [
#     # For each array element, the data structure is illustrated at
#     #     https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone#public-subdomain-zone
#     # 'zone_id' isn't specified because the module will look it up for us.
#     {
#       name = local.domain_name_devops_narvarcorp_net # Record Name: in this case, it's the subdomain name
#       type = "NS"
#       ttl  = "172800" # Value suggested by https://aws.amazon.com/premiumsupport/knowledge-center/create-subdomain-route-53/
#       records = module.route53-zone-devops-narvarcorp-net.route53_zone_name_servers[local.domain_name_devops_narvarcorp_net] # Subdomain's name servers
#     },
#   ]
# }
#
# So, we directly call the terraform resource "aws_route53_record" which is what the module boils down to.
resource "aws_route53_record" "devops-narvarcorp-net" {
  zone_id = local.zone_id_narvarcorp_net            # Parent zone
  name    = local.domain_name_devops_narvarcorp_net # Record Name: in this case, it must be the subdomain name
  type    = "NS"
  ttl     = "172800" # Value suggested by https://aws.amazon.com/premiumsupport/knowledge-center/create-subdomain-route-53/

  records = module.route53-zone-devops-narvarcorp-net.route53_zone_name_servers[local.domain_name_devops_narvarcorp_net] # Subdomain's name servers
}

output "domain_name_devops_narvarcorp_net" {
  value = local.domain_name_devops_narvarcorp_net
}

output "zone_id_devops_narvarcorp_net" {
  value = local.zone_id_devops_narvarcorp_net
}
