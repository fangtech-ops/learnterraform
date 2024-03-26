# See addition comments in ./15-dns-zone-devops-narvar-qa.tf

locals {
  domain_name_qa71_narvar_qa = "qa71.narvar.qa"
}

module "route53-zone-qa71-narvar-qa" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 2.4.0"

  zones = {
    "${local.domain_name_qa71_narvar_qa}" = {
      comment = "ManagedBy: terraform"
    }
  }
}

locals {
  zone_id_qa71_narvar_qa = module.route53-zone-qa71-narvar-qa.route53_zone_zone_id[local.domain_name_qa71_narvar_qa]
}

output "zone_id_qa71_narvar_qa" {
  value = local.zone_id_qa71_narvar_qa
}
