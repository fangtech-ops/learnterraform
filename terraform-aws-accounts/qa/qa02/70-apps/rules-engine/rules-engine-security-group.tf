resource "aws_security_group" "rules_engine" {
  name        = "rules_engine-${local.vpc_name}"
  description = "Rules Engine Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    security_groups = [
      data.aws_security_group.healthcheck-alb.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rules_engine-${local.vpc_name}"
  }
}

