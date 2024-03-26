resource "aws_security_group" "scheduler_queue_processor" {
  name        = "scheduler_queue_processor-${local.vpc_name}"
  description = "Scheduler Queue Processor Security Group"
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
    Name = "scheduler_queue_processor-${local.vpc_name}"
  }
}
