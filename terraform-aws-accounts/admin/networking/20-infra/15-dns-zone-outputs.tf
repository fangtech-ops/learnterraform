output "route53_zone_map" {
  description = "Map of {DNS Domain Name : Route53 Zone ID}"
  value = {
    "${local.domain_name_narvarcorp_net}" : local.zone_id_narvarcorp_net
    "${local.domain_name_devops_narvarcorp_net}" : local.zone_id_devops_narvarcorp_net
    "${local.domain_name_dev71_narvarcorp_net}" : local.zone_id_dev71_narvarcorp_net
    "${local.domain_name_qa71_narvarcorp_net}" : local.zone_id_qa71_narvarcorp_net
    "${local.domain_name_st71_narvarcorp_net}" : local.zone_id_st71_narvarcorp_net
    "${local.domain_name_qa71_narvar_qa}" : local.zone_id_qa71_narvar_qa
  }
}
