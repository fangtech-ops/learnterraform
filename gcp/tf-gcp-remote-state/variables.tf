variable "names" {
  type        = list(any)
  description = "The name of the bucket to create"
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = "Destroy the bucket even if it's not empty"
}

variable "location" {
  type        = string
  description = "The location of the bucket"
}

variable "storage_class" {
  type        = string
  default     = "STANDARD"
  description = "The storage class of the bucket"
}

variable "labels" {
  type        = map(string)
  description = "The labels of the bucket"
  default     = null
}

variable "versioning" {
  type        = bool
  default     = false
  description = "Enable versioning on the bucket"
}

variable "keyring" {
  type        = string
  description = "The keyring to use for encryption"
}

variable "keys" {
  type        = list(any)
  description = "The keys to create"
}

variable "owners" {
  type        = list(any)
  description = "The owners of the bucket"
}

variable "project_id" {
  type        = string
  description = "The project ID to use for the bucket"
}
