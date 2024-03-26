resource "aws_security_group" "scheduler_controller-alb" {
  name        = "scheduler_controller-${local.vpc_name}-alb"
  description = "Scheduler Controller ALB Security Group"
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
    Name = "scheduler_controller-${local.vpc_name}-alb"
  }
}

resource "aws_security_group" "scheduler_controller" {
  name        = "scheduler_controller-${local.vpc_name}"
  description = "Scheduler Controller Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    security_groups = [
      aws_security_group.scheduler_controller-alb.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "scheduler_controller-${local.vpc_name}"
  }
}

resource "aws_alb" "scheduler-controller" {
  name            = "scheduler-controller-${local.vpc_shortname}"
  subnets         = split(",", var.public_subnets)
  internal        = true
  security_groups = [aws_security_group.scheduler_controller-alb.id]

  tags = {
    Name    = "scheduler_controller-${local.vpc_shortname}"
    app     = "scheduler_controller"
    cluster = local.vpc_shortname
    stack = local.vpc_shortname
    sku   = "messaging"
}
}

resource "aws_alb_target_group" "scheduler_controller" {
  name                 = "scheduler-controller-${local.vpc_shortname}"
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

resource "aws_alb_listener" "scheduler_controller-http" {
  load_balancer_arn = aws_alb.scheduler-controller.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.scheduler_controller.arn
    type             = "forward"
  }
}

resource "aws_route53_record" "scheduler_controller" {
  zone_id = var.zone_id_internal
  name    = "scheduler-controller"
  type    = "A"
  alias {
    name                   = aws_alb.scheduler-controller.dns_name
    zone_id                = aws_alb.scheduler-controller.zone_id
    evaluate_target_health = false
  }
}

