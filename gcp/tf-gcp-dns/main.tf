module "dns-zone" {
  source        = "terraform-google-modules/cloud-dns/google"
  version       = "4.1.0"
  project_id    = var.project_id
  type          = var.type
  name          = var.name
  domain        = var.domain
  dnssec_config = var.dnssec_state
  labels = {
    stack : var.stack
  }
}