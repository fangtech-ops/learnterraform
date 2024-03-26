// We need this data block to get the project number
// Will be used to add the default compute engine service account to the encypters and decrypters lists

data "google_project" "project" {
  project_id = var.project_id
}

module "narvar-gcp-kms" {
  source  = "terraform-google-modules/kms/google"
  version = "2.1.0"

  project_id          = var.project_id
  location            = var.location
  keyring             = var.keyring
  keys                = var.keys
  labels              = var.labels
  prevent_destroy     = var.prevent_destroy
  key_rotation_period = var.key_rotation_period


  set_encrypters_for = var.keys
  set_decrypters_for = var.keys

  encrypters = [
    # disk encryption
    "${join(",", [
      "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com",
      "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com",
    ])}",
    # artifact registry
    "serviceAccount:service-${data.google_project.project.number}@gcp-sa-artifactregistry.iam.gserviceaccount.com",
  ]
  decrypters = [
    # disk encryption
    "${join(",", [
      "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com",
      "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com",
    ])}",
    # artifact registry
    "serviceAccount:service-${data.google_project.project.number}@gcp-sa-artifactregistry.iam.gserviceaccount.com",
  ]
}
