
module "workload-identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version             = "20.0.0"
  annotate_k8s_sa     = false
  cluster_name        = var.cluster_name
  gcp_sa_name         = var.gcp_sa_name
  k8s_sa_name         = var.k8s_sa_name
  location            = var.location
  name                = "not_used"
  namespace           = var.namespace
  project_id          = var.project_id
  roles               = var.roles
  use_existing_gcp_sa = false
  use_existing_k8s_sa = true
}

