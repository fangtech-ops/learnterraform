resource "aws_security_group" "returns-front-internal-alb" {
  name = "returns_front_internal-${local.vpc_name}-elb"
  description = "Returns frontend Internal ALB Security Group"
  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "returns_front_internal-${local.vpc_name}-elb"
  }
}

resource "aws_alb" "returns-front-internal" {
  name = "returns-front-internal-${local.vpc_shortname}"
  subnets = split(",", var.private_subnets)
  internal = true
  security_groups = [
    aws_security_group.returns-front-internal-alb.id]

  tags = {
    Name = "returns_front-internal-${local.vpc_shortname}"
    app = "returns_front"
    cluster = local.vpc_shortname
    stack = local.vpc_shortname
    sku = "returns"
  }
}

resource "aws_alb_target_group" "returns-front-internal" {
  name = "returns-front-internal-${local.vpc_shortname}"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
  deregistration_delay = 0

  health_check {
    interval = 10
    port = 80
    path = "/health_check"
    timeout = 5
    healthy_threshold = 3
    unhealthy_threshold = 2
    matcher = 200
  }
}

resource "aws_alb_listener" "returns-front-internal-http" {
  load_balancer_arn = aws_alb.returns-front-internal.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.returns-front-internal.arn
    type = "forward"
  }
}

resource "aws_route53_record" "returns-front-internal" {
  zone_id = var.zone_id_internal
  name = "returns-front-internal"
  type = "A"
  alias {
    name = aws_alb.returns-front-internal.dns_name
    zone_id = aws_alb.returns-front-internal.zone_id
    evaluate_target_health = false
  }
}