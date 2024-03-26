resource "aws_security_group" "template_processor_internal-alb" {
  name        = "template_processor_internal-${local.vpc_name}-alb"
  description = "template_processor internal ALB Security Group"
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
    Name = "template_processor-${local.vpc_name}-elb"
  }
}

resource "aws_security_group" "template_processor_internal" {
  name        = "template_processor_internal-${local.vpc_name}"
  description = "template_processor Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
    security_groups = [
      aws_security_group.template_processor_internal-alb.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "template_processor-${local.vpc_name}"
  }
}

resource "aws_alb" "template_processor_internal" {
  name            = "template-processor-internal-${local.vpc_shortname}"
  subnets         = split(",", var.public_subnets)
  internal        = true
  security_groups = [aws_security_group.template_processor_internal-alb.id]

  tags = {
    Name    = "template_processor-${local.vpc_shortname}"
    app     = "template_processor"
    cluster = local.vpc_shortname
    stack = local.vpc_shortname
    sku   = "messaging"
}
}

resource "aws_alb_target_group" "template_processor_internal" {
  name                 = "template-processor-internal-${local.vpc_shortname}"
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

resource "aws_alb_listener" "template_processor_internal_http" {
  load_balancer_arn = aws_alb.template_processor_internal.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.template_processor_internal.arn
    type             = "forward"
  }
}

resource "aws_route53_record" "template_processor" {
  zone_id = var.zone_id_internal
  name    = "template-processor"
  type    = "A"
  alias {
    name                   = aws_alb.template_processor_internal.dns_name
    zone_id                = aws_alb.template_processor_internal.zone_id
    evaluate_target_health = false
  }
}

resource "aws_security_group" "template_processor_redis" {
  name        = "template_processor_redis-${local.vpc_name}"
  description = " template processor redis Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"
    security_groups = [
      var.bastion_group_id,
      aws_security_group.template_processor_internal.id,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "template_processor_redis-${local.vpc_name}"
  }
}

