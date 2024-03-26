resource "aws_elb" "rabbitmq" {
  name            = "rabbitmq-${local.vpc_shortname}"
  subnets         = split(",", var.public_subnets)
  internal        = true
  security_groups = [aws_security_group.rabbitmq-elb.id]

  cross_zone_load_balancing = true
  idle_timeout              = 60
  connection_draining       = false

  listener {
    lb_protocol        = "HTTPS"
    lb_port            = 443
    instance_protocol  = "HTTP"
    instance_port      = 15672
    ssl_certificate_id = var.ssl_certificate_arn
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 10
    target              = "HTTP:15672/"
  }

  tags = {
    Name    = "rabbitmq-${local.vpc_shortname}"
    app     = "rabbitmq"
    cluster = local.vpc_shortname
    stack   = local.vpc_shortname
  }
}

resource "aws_lb_ssl_negotiation_policy" "rabbitmq_negotiation_policy" {
  name          = "rabbitmq-negotiation-policy"
  load_balancer = aws_elb.rabbitmq.id
  lb_port       = 443

  # protocol preferences
  attribute {
    name  = "Protocol-TLSv1.2"
    value = "true"
  }
  attribute {
    name  = "Server-Defined-Cipher-Order"
    value = "true"
  }

  # cipher preferences
  attribute {
    name  = "ECDHE-ECDSA-AES128-GCM-SHA256"
    value = "true"
  }
  attribute {
    name  = "ECDHE-ECDSA-AES128-SHA256"
    value = "true"
  }
  attribute {
    name  = "ECDHE-ECDSA-AES256-GCM-SHA384"
    value = "true"
  }
  attribute {
    name  = "ECDHE-ECDSA-AES256-SHA384"
    value = "true"
  }
  attribute {
    name  = "ECDHE-RSA-AES128-GCM-SHA256"
    value = "true"
  }
  attribute {
    name  = "ECDHE-RSA-AES128-SHA256"
    value = "true"
  }
  attribute {
    name  = "ECDHE-RSA-AES256-GCM-SHA384"
    value = "true"
  }
  attribute {
    name  = "ECDHE-RSA-AES256-SHA384"
    value = "true"
  }
  attribute {
    name  = "AES128-GCM-SHA256"
    value = "true"
  }
  attribute {
    name  = "AES128-SHA256"
    value = "true"
  }
  attribute {
    name  = "AES256-GCM-SHA384"
    value = "true"
  }
  attribute {
    name  = "AES256-SHA256"
    value = "true"
  }
}

resource "aws_route53_record" "rabbitmq" {
  zone_id = var.zone_id
  name    = "rabbitmq-${local.vpc_shortname}"
  type    = "A"
  alias {
    name                   = aws_elb.rabbitmq.dns_name
    zone_id                = aws_elb.rabbitmq.zone_id
    evaluate_target_health = false
  }
}

resource "aws_security_group" "rabbitmq-elb" {
  name        = "rabbitmq-${local.vpc_name}-elb"
  description = "Rabbitmq ELB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    security_groups = [
      "sg-a2ba5cd8",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rabbitmq-${local.vpc_name}-elb"
  }
}

resource "aws_security_group" "rabbitmq" {
  name        = "rabbitmq-${local.vpc_name}"
  description = "rabbitmq Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 15672
    to_port   = 15672
    protocol  = "tcp"
    security_groups = [
      aws_security_group.rabbitmq-elb.id,
    ]
    self = true
  }

  ingress {
    from_port = 5672
    to_port   = 5672
    protocol  = "tcp"
    security_groups = [
      data.aws_security_group.tracking-back.id, # "data" is defined in rds.tf
      data.aws_security_group.returns-front.id, # "data" is defined in data.tf
      data.aws_security_group.returns-back.id,  # "data" is defined in rds.tf
      data.aws_security_group.orders-api.id,
      data.aws_security_group.exception_lambdas.id, # "data" is defined in rds.tf
      data.aws_security_group.eks_worker.id,
    ]
    self = true
  }

  ingress {
    from_port = 4369
    to_port   = 4369
    protocol  = "tcp"
    self      = true
  }
  ingress {
    from_port = 25672
    to_port   = 25672
    protocol  = "tcp"
    self      = true
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rabbitmq-${local.vpc_name}"
  }
}
