resource "aws_security_group" "comms_rules_engine" {
  name        = "comms_rules_engine-${local.vpc_name}"
  description = "Comms Rules Engine Security Group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "comms_rules_engine-${local.vpc_name}"
  }
}
