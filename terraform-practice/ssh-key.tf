# Define ssh to config in instance
  
# Create default ssh publique key
resource "aws_key_pair" "user_key" {
  key_name   = "charles"
  public_key = file("/tmp/terraform_ec2_key.pub")
}
