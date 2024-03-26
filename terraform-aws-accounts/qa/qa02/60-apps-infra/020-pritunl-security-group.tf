resource "aws_security_group" "pritunl" {
  name        = "pritunl-${local.vpc_name}"
  description = "Pritunl Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 15550
    to_port     = 15570
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pritunl-${local.vpc_name}"
  }
}

