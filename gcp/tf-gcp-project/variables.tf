variable "project_name" {
  type = string
  description = "Name of the project"
}
variable "project_id" {
  type = string
  description = "ID of the project. Usually the same as `project_name`"
}

variable "billing_account" {
  type = string
  description = "Billing account to attach the project to"
}

variable "folder_id" {
  type = string
  description = "Folder to attach the project to"
}
