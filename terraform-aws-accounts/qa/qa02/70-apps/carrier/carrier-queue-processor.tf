resource "aws_kinesis_stream" "tracking-events" {
  name             = "tracking-events-${local.vpc_shortname}"
  shard_count      = 1
  retention_period = 24
  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = {
    Name = "tracking-events-${local.vpc_shortname}"
    stack = local.vpc_shortname
    sku   = "data-services"
  }
}

resource "aws_security_group" "carrier_queue_processor" {
  name        = "carrier_queue_processor-${local.vpc_name}"
  description = "Carrier Queue Processor Security Group"
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
    Name = "carrier_queue_processor-${local.vpc_name}"
  }
}
