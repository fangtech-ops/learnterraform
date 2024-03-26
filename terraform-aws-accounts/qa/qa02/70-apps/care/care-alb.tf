resource "aws_security_group" "care-alb" {
  name        = "care-${local.vpc_name}-alb"
  description = "care ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "care-${local.vpc_name}-elb"
  }
}

resource "aws_security_group" "care" {
  name        = "care-${local.vpc_name}"
  description = "care Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    security_groups = [
      aws_security_group.care-alb.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "care-${local.vpc_name}"
  }
}

resource "aws_alb" "care" {
  name            = "care-${local.vpc_shortname}"
  subnets         = split(",", var.public_subnets)
  internal        = false
  security_groups = [aws_security_group.care-alb.id]

  tags = {
    Name    = "care-${local.vpc_shortname}"
    app     = "care"
    cluster = local.vpc_shortname
    stack = local.vpc_shortname
    sku = "care"
}
}

resource "aws_alb_target_group" "care" {
  name                 = "care-${local.vpc_shortname}"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 0

  health_check {
    interval            = 10
    port                = 80
    path                = "/health_check"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_alb_listener" "care-http" {
  load_balancer_arn = aws_alb.care.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.care.arn
    type             = "forward"
  }
}

resource "aws_alb_listener" "care-https" {
  load_balancer_arn = aws_alb.care.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.alb_security_policy
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.care.arn
    type             = "forward"
  }
}

