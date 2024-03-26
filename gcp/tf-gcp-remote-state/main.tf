module "gcp-bucket" {
  source  = "terraform-google-modules/cloud-storage/google"
  version = "~> 2.2"

  names            = var.names
  prefix           = var.prefix
  randomize_suffix = var.randomize_suffix
  project_id       = var.project_id
  location         = var.location
  storage_class    = var.storage_class
  labels           = var.labels
  depends_on = [
    module.kms-key
  ]
}

module "kms-key" {
  source         = "terraform-google-modules/kms/google"
  version        = "~> 2.1"
  project_id     = var.project_id
  location       = var.location
  keyring        = var.keyring
  keys           = var.keys
  set_owners_for = var.keys
  owners         = var.owners
}
