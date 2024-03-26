# parms file for aws ec2 cloud
variable "aws_access_key" {
    default = ""
}
variable "aws_secret_key" {
    default = ""
}
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}



#### VPC Network
variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/16"
}

#### HTTP PARAMS
variable "network_http" {
  type = map(string)
  default = {
    subnet_name = "subnet_http"
    cidr        = "192.168.1.0/24"
  }
}

# Set number of instance
variable "http_instance_names" {
  type    = set(string)
  default = ["instance-http-1", "instance-http-2", "instance-http-3"]
}

#### DB PARAMS
variable "network_db" {
  type = map(string)
  default = {
    subnet_name = "subnet_db"
    cidr        = "192.168.2.0/24"
  }
}

# Set number of instance
variable "db_instance_names" {
  type    = set(string)
  #default = ["instance-db-1", "instance-db-2", "instance-db-3"]
  default = ["instance-db-1"]
}

