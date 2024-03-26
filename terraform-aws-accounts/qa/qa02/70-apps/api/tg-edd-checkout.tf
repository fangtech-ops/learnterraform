resource "aws_alb_target_group" "edd-checkout-api" {
  name                 = "edd-checkout-api-${local.vpc_shortname}"
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

resource "aws_security_group" "edd-checkout-api" {
  name        = "edd_checkout_api-${local.vpc_name}"
  description = "EDD Checkout API Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    security_groups = [
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
    Name = "edd_checkout_api-${local.vpc_name}"
  }
}
