variable "project_name" {
  type = string
  description = "Name of the project"
  default = "Data Lake"
}

variable "project_id" {
  type = string
  description = "narvar-data-lake"
}

variable "billing_account" {
  type = string
  description = "Billing account to attach the project to"
  default = "doit.narvar.com"
}

variable "folder_id" {
  type = string
  description = "Folder to attach the project to"
}


variable "location" {
  type        = string
  description = "Infrastructure Region"
  default     = "us-west1"
}

variable "zone" {
  type        = string
  description = "Zone"
  default     = "us-west1-a"
}

variable "network_name" {
  type        = string
  description = "Network Name"
  default     = "monitor-base-us"
}

variable "auto_create_subnetworks" {
  type        = bool
  default     = false
}

variable "routing_mode" {
  type        = string
  description = "REGIONAL or GLOBAL"
  default     = "REGIONAL"
}

variable "mtu" {
  type        = number
  default     = 1460
}

variable "subnet" {
  type        = string
  description = "Subnet Name"
  default     = "monitor-us-qa"
}

variable "cidr_ip" {
  default = "0.0.0.0/0"
}

# define private subnet
variable "private_subnet_cidr_1" {
  type        = string
  description = "private subnet CIDR 1"
  default     = "192.168.1.0/24"
}

# define private subnet
variable "private_subnet_cidr_2" {
  type        = string
  description = "private subnet CIDR 2"
  default     = "192.168.2.0/24"
}

variable "name" {
  type        = string
  description = "The base name of resources"
  default     = "metabase"
}


variable "deploy_version" {
  type        = string
  description = "Deployment Version"
  default     = "v1"
}

variable "image" {
  type        = string
  description = "VM Image for Instance Template"
  default     = "metabase-9"
}

variable "tags" {
  type        = list(any)
  description = "Network Tags for resources"
  default     = ["metabase"]
}

variable "machine_type" {
  type        = string
  description = "VM Size"
  default     = "n1-standard-1"
}



variable "minimum_vm_size" {
  type        = number
  description = "Minimum VM size in Instance Group"
  default     = 2
}

variable "instance_description" {
  type        = string
  description = "Description assigned to instances"
  default     = "This template is used to create metabase server instances"
}

variable "instance_group_manager_description" {
  type        = string
  description = "Description of instance group manager"
  default     = "Instance group for metabase server"
}

variable "instance_template_description" {
  type        = string
  description = "Description of instance template"
  default     = "metabase server template"
}

variable "enable_ssl" {
  description = "Set to true to enable ssl. If set to 'true', you will also have to provide 'var.custom_domain_name'."
  type        = bool
  default     = false
}

variable "enable_http" {
  description = "Set to true to enable plain http. Note that disabling http does not force SSL and/or redirect HTTP traffic. See https://issuetracker.google.com/issues/35904733"
  type        = bool
  default     = true
}

variable "static_content_bucket_location" {
  description = "Location of the bucket that will store the static content. Once a bucket has been created, its location can't be changed. See https://cloud.google.com/storage/docs/bucket-locations"
  type        = string
  default     = "US"
}

variable "create_dns_entry" {
  description = "If set to true, create a DNS A Record in Cloud DNS for the domain specified in 'custom_domain_name'."
  type        = bool
  default     = false
}

variable "custom_domain_name" {
  description = "Custom domain name."
  type        = string
  default     = ""
}

variable "dns_managed_zone_name" {
  description = "The name of the Cloud DNS Managed Zone in which to create the DNS A Record specified in var.custom_domain_name. Only used if var.create_dns_entry is true."
  type        = string
  default     = "replace-me"
}

variable "dns_record_ttl" {
  description = "The time-to-live for the load balancer A record (seconds)"
  type        = string
  default     = 60
}

variable "custom_labels" {
  description = "A map of custom labels to apply to the resources. The key is the label name and the value is the label value."
  type        = map(string)

  default = {}
}

# Google Cloud connection & authentication and Application configuration | variables-auth.tf

# GCP authentication file
variable "gcp_auth_file" {
  type        = string
  description = "GCP authentication file"
  default     = ""
}


# define application name
variable "app_name" {
  type        = string
  description = "Application name"
  default     = "metabase"
}

# define application domain
variable "app_domain" {
  type        = string
  description = "Application domain"
  default     = "narvar.com"
}

# define application environment
variable "app_environment" {
  type        = string
  description = "Application environment"
  default     = "dev"
}

variable "app_node_count" {
  type        = string
  description = "Number of servers to build"
  default     = "1"
}
