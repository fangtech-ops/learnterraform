variable "aws_amis" {
  type = map
  default = {
    "eu-west-1" = "ami-0d5ae304a0b933620"
    "us-east-1" = "ami-de7ab6b6"
    "us-west-1" = "ami-005c06c6de69aee84"
    "us-west-2" = "ami-0a70b9d193ae8a799"
  }
}
