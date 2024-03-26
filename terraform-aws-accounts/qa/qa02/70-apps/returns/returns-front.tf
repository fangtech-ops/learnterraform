resource "aws_security_group" "returns-front-alb" {
  name        = "returns_front-${local.vpc_name}-elb"
  description = "Returns frontend ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    Name = "returns_front-${local.vpc_name}-elb"
  }
}

resource "aws_security_group" "returns-front" {
  name        = "returns_front-${local.vpc_name}"
  description = "Returns frontend Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    security_groups = [
      aws_security_group.returns-front-alb.id,
      aws_security_group.returns-front-internal-alb.id,
    ]
  }

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    security_groups = [
      data.aws_security_group.healthcheck-alb.id,
      data.aws_security_group.jenkins_aws_security_group.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "returns_front-${local.vpc_name}"
  }
}

resource "aws_alb" "returns-front" {
  name            = "returns-front-${local.vpc_shortname}"
  subnets         = split(",", var.public_subnets)
  internal        = false
  security_groups = [aws_security_group.returns-front-alb.id]

  tags = {
    Name    = "returns_front-${local.vpc_shortname}"
    app     = "returns_front"
    cluster = local.vpc_shortname
    stack = local.vpc_shortname
    sku = "returns"
}
}

resource "aws_alb_target_group" "returns-front" {
  name                 = "returns-front-${local.vpc_shortname}"
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

resource "aws_alb_listener" "returns-front-https" {
  load_balancer_arn = aws_alb.returns-front.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.alb_security_policy
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.returns-front.arn
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "returns-front-https-listener-rule" {
  listener_arn = aws_alb_listener.returns-front-https.arn
  priority     = 100

  action {
    type = "redirect"

    redirect {
      host = "corp.narvar.com"
      path = "/return"
      port = "443"
      protocol = "HTTPS"
      query = "#{query}"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
    values = ["/"]
    }
  }

  condition {
    host_header {
    values = ["returns-qa02.narvar.qa"]
    }
  }

}

resource "aws_alb_listener_rule" "returns-front-https-listener-rule-2" {
  listener_arn = aws_alb_listener.returns-front-https.arn
  priority     = 110

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "No Access"
      status_code  = "403"
    }
  }

  condition {
    path_pattern {
      values = [
        "/returns/details*"]
    }
  }

}

resource "aws_alb_listener_rule" "returns-front-https-listener-rule-3" {
  listener_arn = aws_alb_listener.returns-front-https.arn
  priority     = 120

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "No Access"
      status_code  = "403"
    }
  }

  condition {
    path_pattern {
      values = [
        "/api/v1/pickups/config/*"]
    }
  }

}

resource "aws_alb_listener" "returns-front-http" {
  load_balancer_arn = aws_alb.returns-front.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_route53_record" "returns" {
  zone_id = var.zone_id
  name    = "returns-${local.vpc_shortname}"
  type    = "A"
  alias {
    name                   = aws_alb.returns-front.dns_name
    zone_id                = aws_alb.returns-front.zone_id
    evaluate_target_health = false
  }
}

