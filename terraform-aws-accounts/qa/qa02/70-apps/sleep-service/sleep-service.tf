resource "aws_security_group" "sleep_service_alb" {
  name        = "sleep-service-${local.vpc_name}-alb"
  description = "Sleep Service ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sleep-service-${local.vpc_name}-alb"
  }
}

resource "aws_security_group" "sleep_service" {
  name        = "sleep-service-${local.vpc_name}"
  description = "Sleep Service Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    security_groups = [
      aws_security_group.sleep_service_alb.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sleep-service-${local.vpc_name}"
  }
}

resource "aws_alb" "sleep_service" {
  name            = "sleep-service-${local.vpc_shortname}"
  subnets         = split(",", var.private_subnets)
  internal        = true
  security_groups = [aws_security_group.sleep_service_alb.id]

  tags = {
    Name    = "sleep-service-${local.vpc_shortname}"
    app     = "sleep_service"
    cluster = local.vpc_shortname
    stack = local.vpc_shortname
    sku   = "messaging"
}
}

resource "aws_alb_target_group" "sleep_service" {
  name                 = "sleep-service-${local.vpc_shortname}"
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 0

  health_check {
    interval            = 10
    port                = 8080
    path                = "/health_check"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_alb_listener" "sleep_service_http" {
  load_balancer_arn = aws_alb.sleep_service.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.sleep_service.arn
    type             = "forward"
  }
}

resource "aws_route53_record" "sleep_service" {
  zone_id = var.zone_id_internal
  name    = "sleep-service"
  type    = "A"
  alias {
    name                   = aws_alb.sleep_service.dns_name
    zone_id                = aws_alb.sleep_service.zone_id
    evaluate_target_health = false
  }
}

