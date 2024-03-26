resource "aws_security_group" "notify_external_webhook-alb" {
  name        = "notify_external_webhook-${local.vpc_name}-alb"
  description = "Notify External Webhook ALB Security Group"
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
    Name = "notify_external_webhook-${local.vpc_name}-alb"
  }
}

resource "aws_security_group" "notify_external_webhook" {
  name        = "notify_external_webhook-${local.vpc_name}"
  description = "Notify External Webhook Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    security_groups = [
      aws_security_group.notify_external_webhook-alb.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "notify_external_webhook-${local.vpc_name}"
  }
}

resource "aws_alb" "notify-external-webhook" {
  name            = "notify-external-webhook-${local.vpc_shortname}"
  subnets         = split(",", var.public_subnets)
  internal        = true
  security_groups = [aws_security_group.notify_external_webhook-alb.id]

  tags = {
    Name    = "notify_external_webhook-${local.vpc_shortname}"
    app     = "notify_external_webhook"
    cluster = local.vpc_shortname
    stack = local.vpc_shortname
    sku = "messaging"
}
}

resource "aws_alb_target_group" "notify_external_webhook" {
  name                 = "notify-external-webhook-${local.vpc_shortname}"
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

resource "aws_alb_listener" "notify_external_webhook-http" {
  load_balancer_arn = aws_alb.notify-external-webhook.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.notify_external_webhook.arn
    type             = "forward"
  }
}

resource "aws_route53_record" "notify_external_webhook" {
  zone_id = var.zone_id_internal
  name    = "notify-external-webhook"
  type    = "A"
  alias {
    name                   = aws_alb.notify-external-webhook.dns_name
    zone_id                = aws_alb.notify-external-webhook.zone_id
    evaluate_target_health = false
  }
}

