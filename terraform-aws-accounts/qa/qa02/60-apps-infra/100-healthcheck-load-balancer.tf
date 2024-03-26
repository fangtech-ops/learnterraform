resource "aws_alb" "healthcheck" {
  name            = "healthcheck-${local.vpc_shortname}"
  subnets         = split(",", var.public_subnets)
  internal        = true
  security_groups = [aws_security_group.healthcheck-alb.id]

  tags = {
    Name    = "healthcheck-${local.vpc_shortname}"
    app     = "healthcheck"
    cluster = local.vpc_shortname
    stack   = local.vpc_shortname
    sku     = "devops"
  }
}

resource "aws_alb_target_group" "healthcheck" {
  name                 = "healthcheck-${local.vpc_shortname}"
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

resource "aws_alb_listener" "healthcheck" {
  load_balancer_arn = aws_alb.healthcheck.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.healthcheck.arn
    type             = "forward"
  }
}

resource "aws_security_group" "healthcheck-alb" {
  name        = "healthcheck-${local.vpc_name}-alb"
  description = "Healthcheck ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
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
    Name = "healthcheck-${local.vpc_name}-alb"
  }
}
