variable "cluster_name" {
  description = "Cluster name. Required if using existing KSA."
  type        = string
}

variable "gcp_sa_name" {
  description = "Name for the Google service account"
  type        = string
}

variable "k8s_sa_name" {
  description = "Name for the Kubernetes service account"
  type        = string
}

variable "location" {
  description = "Cluster location (region if regional cluster, zone if zonal cluster). Required if using existing KSA."
  type        = string
}

variable "namespace" {
  description = "Namespace for the Kubernetes service account"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "roles" {
  description = "A list of roles to be added to the created service account"
  type        = list(string)
  default     = []
}