output "cluster_id" {
  value = google_container_cluster.this.id
  description = "The ID of the cluster"
}

output "endpoint" {
 value = google_container_cluster.this.endpoint
 description = "The endpoint of the cluster"
}

output "client_certificate" {
  value = google_container_cluster.this.master_auth.0.client_certificate
  description = "The client certificate of the cluster"
}

output "client_key" {
  value = google_container_cluster.this.master_auth.0.client_key
  description = "The client key of the cluster"
}

output "master_version" {
  value = google_container_cluster.this.master_version
  description = "The version of the API server"
}

