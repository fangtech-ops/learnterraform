resource "aws_redshift_subnet_group" "default" {
  name       = "redshift-subnet-group-${local.vpc_shortname}"
  subnet_ids = split(",", var.private_subnets)

  tags = {
    Name = local.vpc_name
  }
}

resource "aws_security_group" "redshift" {
  name        = "redshift-${local.vpc_name}"
  description = "Redshift database Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5439
    to_port   = 5439
    protocol  = "tcp"
    security_groups = [
      var.bastion_group_id,
      aws_security_group.analytics-api.id,
      data.aws_security_group.eks_worker.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redshift-${local.vpc_name}"
  }
}

