data "aws_route53_zone" "narvarcorp_net" {
  # This public DNS domain was originally registered manually.
  # See: ../10-bootstrap/README.md#4-register-a-public-dns-domain-in-route-53-registrar
  name         = local.domain_name_narvarcorp_net
  private_zone = false
}

locals {
  zone_id_narvarcorp_net = data.aws_route53_zone.narvarcorp_net.zone_id
}

output "zone_id_narvarcorp_net" {
  value = local.zone_id_narvarcorp_net
}
