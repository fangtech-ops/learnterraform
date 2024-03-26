resource "aws_security_group" "mongodb" {
  name        = "mongodb-${local.vpc_name}"
  description = "MongoDB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 27017
    to_port   = 27017
    protocol  = "tcp"
    security_groups = [
      var.bastion_group_id,
      data.aws_security_group.assist.id,
    ]
    self = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mongodb-${local.vpc_name}"
  }
}
