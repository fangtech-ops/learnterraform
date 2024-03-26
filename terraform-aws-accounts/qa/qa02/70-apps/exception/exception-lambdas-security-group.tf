resource "aws_security_group" "exception_lambdas" {
  name        = "exception_lambdas-${local.vpc_name}"
  description = "Exception Lambdas Security Group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "exception_lambdas-${local.vpc_name}"
  }
}

