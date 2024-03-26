resource "google_container_cluster" "this" {
  project = var.project
  name      = var.cluster_name
  location = var.location
  node_locations     = var.node_locations
  network   = var.network
  remove_default_node_pool = true
  initial_node_count = 1
}

resource "google_container_node_pool" "this" {
  name = "${var.cluster_name}-node-pool"
  location = "${google_container_cluster.this.location}"
  cluster = "${google_container_cluster.this.name}"
  node_count = var.node_count
  project = var.project
  node_config {
    preemptible = true
    machine_type = var.machine_type
  }
}


