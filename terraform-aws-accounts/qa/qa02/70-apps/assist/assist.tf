resource "aws_security_group" "assist-alb" {
  name        = "assist-${local.vpc_name}-alb"
  description = "Assist ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

#  ingress {
#    from_port   = 80
#    to_port     = 80
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "assist-${local.vpc_name}-elb"
  }
}

resource "aws_security_group" "assist" {
  name        = "assist-${local.vpc_name}"
  description = "Assist Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5000
    to_port   = 5000
    protocol  = "tcp"
    security_groups = [
      aws_security_group.assist-alb.id,
    ]
  }

  ingress {
    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
    security_groups = [
      aws_security_group.assist-alb.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "assist-${local.vpc_name}"
  }
}

resource "aws_alb" "assist" {
  name            = "assist-${local.vpc_shortname}"
  subnets         = split(",", var.public_subnets)
  internal        = false
  security_groups = [aws_security_group.assist-alb.id]

  tags = {
    Name    = "assist-${local.vpc_shortname}"
    app     = "assist"
    cluster = local.vpc_shortname
    stack = local.vpc_shortname
    sku   = "track"
}
}

resource "aws_alb_target_group" "assist" {
  name                 = "assist-${local.vpc_shortname}"
  port                 = 5000
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 0

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 604800
    enabled         = true
  }

  health_check {
    interval            = 10
    port                = 5000
    path                = "/health_check"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = 200
  }
}

#resource "aws_alb_listener" "assist-http" {
#  load_balancer_arn = aws_alb.assist.arn
#  port              = "80"
#  protocol          = "HTTP"
#
#  default_action {
#    target_group_arn = aws_alb_target_group.assist.arn
#    type             = "forward"
#  }
#}

resource "aws_alb_listener" "assist-https" {
  load_balancer_arn = aws_alb.assist.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.alb_security_policy
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.assist.arn
    type             = "forward"
  }
}

