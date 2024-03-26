variable "project" {
  type = string
  description = "Project ID for this cluster"
}

variable "cluster_name" {
  type = string
  description = "Name of the cluster"
}

variable "location" {
  type = string
  description = "Location of the cluster"
}


variable "node_locations" {
  type = list
  description = "Locations of the nodes"
}

variable "network" {
  type = string
  description = "(optional) describe your variable"
}

variable "node_count" {
  type = number
  description = "(optional) describe your variable"
}

variable "machine_type" {
  type = string
  description = "(optional) describe your variable"
}
