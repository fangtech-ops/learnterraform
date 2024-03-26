variable "project_id" {
  type        = string
  description = "The Google Cloud project ID to use"
}

variable "location" {
  type        = string
  description = "The location to use"
}

variable "keyring" {
  type        = string
  description = "The keyring to use"
}

variable "keys" {
  type        = list(string)
  description = "Keys to create"
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to the keys"
}

variable "prevent_destroy" {
  type        = bool
  description = "Whether to prevent destroy"
  default     = true
}

variable "key_rotation_period" {
  type        = string
  description = "The key rotation period"
  default     = "604800s"
}

