variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.

Example: ~/.ssh/terraform.pub
DESCRIPTION
    default = "/Users/charles.lee/.ssh/terraform.pub"

}
variable "aws_access_key" {
    default = ""
}
variable "aws_secret_key" {
    default = ""
}
variable "aws_key_path" {
    default = "/Users/charles.lee/.ssh/terraform"
}
variable "aws_key_name" {
  description = "Desired name of AWS key pair"
  default = "terraform"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

# Ubuntu 20.04 LTS (x64)
variable "aws_amis" {
  default = {
    eu-west-1 = "ami-b1cf19c6"
    us-east-1 = "ami-de7ab6b6"
    us-west-1 = "ami-3f75767a"
    us-west-2 = "ami-0e999cbd62129e3b1"
  }
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "unused_subnet_cidr" {
    description = "CIDR for the unused Subnet"
    default = "10.0.0.0/24"
}

variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.1.0/24"
}
