# parms file for aws ec2 cloud
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}


# parms file for aws ec2 cloud

#### VPC Network
variable "vpc_cidr" {
  type    = string
  default = "10.31.0.0/16"
}

#### API
variable "network_admin1" {
  type = map(string)
  default = {
    subnet_name = "subnet_admin1"
    cidr        = "10.31.21.0/24"
  }
}
variable "network_admin2" {
  type = map(string)
  default = {
    subnet_name = "subnet_admin2"
    cidr        = "10.31.22.0/24"
  }
}

#### HTTP PARAMS
variable "network_http1" {
  type = map(string)
  default = {
    subnet_name = "subnet_http1"
    cidr        = "10.31.31.0/24"
  }
}
variable "network_http2" {
  type = map(string)
  default = {
    subnet_name = "subnet_http2"
    cidr        = "10.31.32.0/24"
  }
}
variable "network_http3" {
  type = map(string)
  default = {
    subnet_name = "subnet_http3"
    cidr        = "10.31.33.0/24"
  }
}


# Set number of instance
variable "admin1_instance_names" {
  type    = set(string)
  default = ["instance-admin-1"]
}

# Set number of instance
variable "admin2_instance_names" {
  type    = set(string)
  default = ["instance-admin-2"]
}




