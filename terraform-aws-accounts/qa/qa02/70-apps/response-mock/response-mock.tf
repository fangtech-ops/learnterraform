resource "aws_security_group" "response_mock-elb" {
  name        = "response_mock-${local.vpc_name}-elb"
  description = "Response Mock Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      local.vpc_cidr,
      var.qa01_vpc_cidr,
      var.st01_vpc_cidr,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "response_mock-${local.vpc_name}-elb"
  }
}

resource "aws_security_group" "response_mock" {
  name        = "response_mock-${local.vpc_name}"
  description = "Response Mock Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    security_groups = [
      aws_security_group.response_mock-elb.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "response_mock-${local.vpc_name}"
  }
}

resource "aws_elb" "response_mock" {
  name            = "response-mock-${local.vpc_shortname}"
  subnets         = split(",", var.private_subnets)
  internal        = true
  security_groups = [aws_security_group.response_mock-elb.id]

  cross_zone_load_balancing = true
  idle_timeout              = 60
  connection_draining       = false

  listener {
    lb_protocol       = "HTTP"
    lb_port           = 80
    instance_protocol = "HTTP"
    instance_port     = 8080
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 10
    target              = "TCP:8080"
  }

  tags = {
    Name    = "response_mock-${local.vpc_shortname}"
    app     = "response_mock"
    cluster = local.vpc_shortname
    stack = local.vpc_shortname
}
}

resource "aws_route53_record" "response_mock" {
  zone_id = var.zone_id_internal
  name    = "response-mock"
  type    = "A"
  alias {
    name                   = aws_elb.response_mock.dns_name
    zone_id                = aws_elb.response_mock.zone_id
    evaluate_target_health = false
  }
}

