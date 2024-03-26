resource "aws_security_group" "consumer_notify_prefs-alb" {
  name        = "consumer_notify_prefs-${local.vpc_name}-alb"
  description = "Retailer Notify Prefs ALB Security Group"
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
    Name = "consumer_notify_prefs-${local.vpc_name}-alb"
  }
}

resource "aws_security_group" "consumer_notify_prefs" {
  name        = "consumer_notify_prefs-${local.vpc_name}"
  description = "Retailer Notify Prefs Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    security_groups = [
      aws_security_group.consumer_notify_prefs-alb.id,
      data.aws_security_group.api-alb.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "consumer_notify_prefs-${local.vpc_name}"
  }
}

resource "aws_alb" "consumer-notify-prefs" {
  name            = "consumer-notify-prefs-${local.vpc_shortname}"
  subnets         = split(",", var.public_subnets)
  internal        = true
  security_groups = [aws_security_group.consumer_notify_prefs-alb.id]

  tags = {
    Name    = "consumer_notify_prefs-${local.vpc_shortname}"
    app     = "consumer_notify_prefs"
    cluster = local.vpc_shortname
    stack   = local.vpc_shortname
    sku     = "messaging"
  }
}

resource "aws_alb_target_group" "consumer_notify_prefs_external" {
  name                 = "consumer-notify-external-${local.vpc_shortname}"
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 0

  health_check {
    interval            = 10
    port                = 8080
    path                = "/health"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_alb_target_group" "consumer_notify_prefs_internal" {
  name                 = "consumer-notify-internal-${local.vpc_shortname}"
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 0

  health_check {
    interval            = 10
    port                = 8080
    path                = "/health"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_alb_listener" "consumer_notify_prefs-http" {
  load_balancer_arn = aws_alb.consumer-notify-prefs.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.consumer_notify_prefs_internal.arn
    type             = "forward"
  }
}

resource "aws_route53_record" "consumer_notify_prefs" {
  zone_id = var.zone_id_internal
  name    = "consumer-notify-prefs"
  type    = "A"
  alias {
    name                   = aws_alb.consumer-notify-prefs.dns_name
    zone_id                = aws_alb.consumer-notify-prefs.zone_id
    evaluate_target_health = false
  }
}
