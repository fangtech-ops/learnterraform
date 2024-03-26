resource "aws_security_group" "generic_scheduler" {
  name        = "generic_scheduler-${local.vpc_name}"
  description = "Generic Scheduler redis Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"
    security_groups = [
      var.bastion_group_id,
      data.aws_security_group.quartz_trigger.id,
      data.aws_security_group.eks_worker.id,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "generic_scheduler-${local.vpc_name}"
  }
}

