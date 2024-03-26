resource "aws_security_group" "toran-alb" {
  name        = "toran-${local.vpc_name}-alb"
  description = "Toran ALB Security Group"
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
    Name = "toran-${local.vpc_name}-alb"
  }
}

resource "aws_security_group" "toran" {
  name        = "toran-${local.vpc_name}"
  description = "Toran Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 3337
    to_port   = 3337
    protocol  = "tcp"
    security_groups = [
      aws_security_group.toran-alb.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "toran-${local.vpc_name}"
  }
}

resource "aws_alb" "toran" {
  name            = "toran-${local.vpc_shortname}"
  subnets         = split(",", var.private_subnets)
  internal        = true
  security_groups = [aws_security_group.toran-alb.id]

  tags = {
    Name    = "toran-${local.vpc_shortname}"
    app     = "toran"
    cluster = local.vpc_shortname
    stack = local.vpc_shortname
    sku   = "shared-services"
}
}

resource "aws_alb_target_group" "toran" {
  name                 = "toran-${local.vpc_shortname}"
  port                 = 3337
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 0

  health_check {
    interval            = 10
    port                = 3337
    path                = "/health_check"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_alb_listener" "toran-http" {
  load_balancer_arn = aws_alb.toran.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.toran.arn
    type             = "forward"
  }
}

resource "aws_route53_record" "toran" {
  zone_id = var.zone_id_internal
  name    = "toran"
  type    = "A"
  alias {
    name                   = aws_alb.toran.dns_name
    zone_id                = aws_alb.toran.zone_id
    evaluate_target_health = false
  }
}

