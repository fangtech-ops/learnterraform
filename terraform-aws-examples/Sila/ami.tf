# Ubuntu 20.04 LTS (x64)
variable "aws_amis" {
  type = map
  default = {
    "eu-west-1" = "ami-b1cf19c6"
    "us-east-1" = "ami-de7ab6b6"
    "us-west-1" = "ami-3f75767a"
    "us-west-2" = "ami-0928f4202481dfdf6"
  }
}
