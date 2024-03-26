variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "type" {
  description = "Type of zone to create, valid values are 'public', 'private', 'forwarding', 'peering'"
  type        = string
}

variable "name" {
  description = "Name of the DNS Zone"
  type        = string
}

variable "domain" {
  description = "Domain value"
  type        = string
}

variable "stack" {
  description = "Stack value"
  type        = string
}

variable "dnssec_state" {
  type        = map(string)
  description = "Turn on DNSSEC for the zone"
  default = {
    state = "on"
  }
}
