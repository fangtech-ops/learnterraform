output "k8s_service_account_name" {
  description = "Name of k8s service account."
  value       = module.workload-identity.k8s_service_account_name
}

output "k8s_service_account_namespace" {
  description = "Namespace of k8s service account."
  value       = module.workload-identity.k8s_service_account_namespace
}

output "gcp_service_account_email" {
  description = "Email address of GCP service account."
  value       = module.workload-identity.gcp_service_account_email
}

output "gcp_service_account_fqn" {
  description = "FQN of GCP service account."
  value       = module.workload-identity.gcp_service_account_fqn
}

output "gcp_service_account_name" {
  description = "Name of GCP service account."
  value       = module.workload-identity.gcp_service_account_name
}

output "gcp_service_account" {
  description = "GCP service account."
  value       = module.workload-identity.gcp_service_account
}