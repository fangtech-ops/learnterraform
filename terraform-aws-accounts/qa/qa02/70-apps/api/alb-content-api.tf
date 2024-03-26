resource "aws_alb" "content_api" {
  name            = "content-api-${local.vpc_shortname}"
  subnets         = split(",", var.private_subnets)
  internal        = true
  security_groups = [aws_security_group.content_api-alb.id]

  tags = {
    Name    = "content_api-${local.vpc_shortname}"
    app     = "content_api"
    cluster = local.vpc_shortname
    stack   = local.vpc_shortname
    sku     = "care"
  }
}

resource "aws_alb_target_group" "content_api" {
  name                 = "content-api-${local.vpc_shortname}"
  port                 = 3000
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 0

  health_check {
    interval            = 10
    port                = 3000
    path                = "/health_check"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_alb_listener" "content_api-http" {
  load_balancer_arn = aws_alb.content_api.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.content_api.arn
    type             = "forward"
  }
}

resource "aws_route53_record" "content_api" {
  zone_id = var.zone_id_internal
  name    = "content-api"
  type    = "A"
  alias {
    name                   = aws_alb.content_api.dns_name
    zone_id                = aws_alb.content_api.zone_id
    evaluate_target_health = false
  }
}

resource "aws_security_group" "content_api-alb" {
  name        = "content_api-${local.vpc_name}-alb"
  description = "content_api Internal ALB Security Group"
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
    Name = "content_api-${local.vpc_name}-elb"
  }
}

resource "aws_security_group" "content_api" {
  name        = "content_api-${local.vpc_name}"
  description = "content_api Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
    security_groups = [
      aws_security_group.content_api-alb.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "content_api-${local.vpc_name}"
  }
}
