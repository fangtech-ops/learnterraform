resource "aws_security_group" "analytics-api-alb" {
  name        = "analytics-api-${local.vpc_name}-alb"
  description = "Analytics API ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    security_groups = [
      # aws_security_group.eks_worker.id
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
    Name = "analytics_api-${local.vpc_name}-alb"
  }
}

resource "aws_security_group" "analytics-api" {
  name        = "analytics_api-${local.vpc_name}"
  description = "Analytics-API Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5000
    to_port   = 5000
    protocol  = "tcp"
    security_groups = [
      aws_security_group.analytics-api-alb.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "analytics_api-${local.vpc_name}"
  }
}

resource "aws_alb" "analytics-api" {
  name            = "analytics-api-${local.vpc_shortname}"
  subnets         = split(",", var.private_subnets)
  internal        = true
  security_groups = [aws_security_group.analytics-api-alb.id]
  idle_timeout = 180

  tags = {
    Name    = "analytics_api-${local.vpc_shortname}"
    app     = "analytics_api"
    cluster = local.vpc_shortname
    stack = local.vpc_shortname
    sku = "data-platform"
}
}

resource "aws_alb_target_group" "analytics-api" {
  name                 = "analytics-api-${local.vpc_shortname}"
  port                 = 5000
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 0

  health_check {
    interval            = 10
    port                = 5000
    path                = "/ping"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_alb_listener" "analytics-api-https" {
  load_balancer_arn = aws_alb.analytics-api.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.alb_security_policy
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.analytics-api.arn
    type             = "forward"
  }
}

resource "aws_route53_record" "analytics-api-internal" {
  zone_id = var.zone_id_internal
  name    = "analytics-api"
  type    = "A"
  alias {
    name                   = aws_alb.analytics-api.dns_name
    zone_id                = aws_alb.analytics-api.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "analytics-api" {
  zone_id = var.zone_id
  name    = "analytics-api-${local.vpc_shortname}"
  type    = "A"
  alias {
    name                   = aws_alb.analytics-api.dns_name
    zone_id                = aws_alb.analytics-api.zone_id
    evaluate_target_health = false
  }
}

