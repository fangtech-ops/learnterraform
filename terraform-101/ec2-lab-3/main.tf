#Provider Block
provider "aws" {
    region = "us-east-2"
}

#EC2 Block w/tags
resource "aws_instance" "tags-test" {
    ami = "ami-0e999cbd62129e3b1"
    instance_type = "t2.micro"
    #Add Tags

}
