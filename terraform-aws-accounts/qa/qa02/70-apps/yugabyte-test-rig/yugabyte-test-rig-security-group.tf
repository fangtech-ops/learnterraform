resource "aws_security_group" "yugabyte_test_rig" {
  name        = "yugabyte_test_rig-${local.vpc_name}"
  description = "yugabyte_test_rig Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "yugabyte_test_rig-${local.vpc_name}"
  }
}