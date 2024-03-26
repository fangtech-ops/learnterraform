resource "aws_alb" "api" {
  name     = "api-${local.vpc_shortname}"
  subnets  = split(",", var.public_subnets)
  internal = false
  security_groups = [
  aws_security_group.api-alb.id]

  tags = {
    Name    = "api-${local.vpc_shortname}"
    app     = "api"
    cluster = local.vpc_shortname
    stack   = local.vpc_shortname
    sku     = "shared-services"
  }
}

resource "aws_alb_listener" "api-http" {
  load_balancer_arn = aws_alb.api.arn
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

resource "aws_alb_listener" "api-https" {
  load_balancer_arn = aws_alb.api.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.alb_security_policy
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.orders-api.arn
    type             = "forward"
  }
}

#resource "aws_alb_listener_rule" "action-api-rule-http" {
#  listener_arn = aws_alb_listener.api-http.arn
#  priority     = 120
#
#  action {
#    type             = "forward"
#    target_group_arn = aws_alb_target_group.action-api.arn
#  }
#
#  condition {
#    field  = "path-pattern"
#    values = ["/api/v1/event*"]
#  }
#}

resource "aws_alb_listener_rule" "action-api-rule-https" {
  listener_arn = aws_alb_listener.api-https.arn
  priority     = 120

  action {
    type             = "forward"
    target_group_arn = data.aws_alb_target_group.messaging-action-api.arn
  }

  condition {
    path_pattern {
      values = [
      "/api/v1/event*"]
    }
  }
}

resource "aws_alb_listener_rule" "consumer-notify-prefs-rule-https" {
  listener_arn = aws_alb_listener.api-https.arn
  priority     = 110

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.consumer_notify_prefs_external.arn
  }

  condition {
    path_pattern {
      values = [
      "/api/v1/notify-preferences/*"]
    }
  }
}

resource "aws_alb_listener_rule" "orders-api-rule-https" {
  listener_arn = aws_alb_listener.api-https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.orders-api.arn
  }

  condition {
    path_pattern {
      values = [
      "/api/v1/orders/*"]
    }
  }
}

#resource "aws_alb_listener_rule" "orders-api-rule-http" {
#  listener_arn = aws_alb_listener.api-http.arn
#  priority     = 100
#
#  action {
#    type             = "forward"
#    target_group_arn = aws_alb_target_group.orders-api.arn
#  }
#
#  condition {
#    field  = "path-pattern"
#    values = ["/api/v1/orders/*"]
#  }
#}

resource "aws_alb_listener_rule" "iteminfo-api-rule-https" {
  listener_arn = aws_alb_listener.api-https.arn
  priority     = 90

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.orders-api.arn
  }

  condition {
    path_pattern {
      values = [
      "/iteminfo/*"]
    }
  }
}

#resource "aws_alb_listener_rule" "iteminfo-api-rule-http" {
#  listener_arn = aws_alb_listener.api-http.arn
#  priority     = 90
#
#  action {
#    type             = "forward"
#    target_group_arn = aws_alb_target_group.orders-api.arn
#  }
#
#  condition {
#    field  = "path-pattern"
#    values = ["/iteminfo/*"]
#  }
#}

resource "aws_alb_listener_rule" "edd-checkout-api-rule-https" {
  listener_arn = aws_alb_listener.api-https.arn
  priority     = 80

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.edd-checkout-api.arn
  }

  condition {
    path_pattern {
      values = [
      "/api/v1/eddCheckout"]
    }
  }
}

resource "aws_alb_listener_rule" "tracking-new-api-rule-https" {
  listener_arn = aws_alb_listener.api-https.arn
  priority     = 70

  action {
    type             = "forward"
    target_group_arn = data.aws_alb_target_group.tracking_k8s.arn
  }

  condition {
    path_pattern {
      values = [
      "/api/v1/tracking*"]
    }
  }
}

resource "aws_alb_listener_rule" "carrier-data-ingestion-rule-https" {
  listener_arn = aws_alb_listener.api-https.arn
  priority     = 55

  action {
    type             = "forward"
    target_group_arn = data.aws_alb_target_group.carrier-data-ingestion.arn
  }

  condition {
    path_pattern {
      values = [
      "/api/v1/carrier-data*"]
    }
  }
}

resource "aws_alb_listener_rule" "tracking-orders-rule-https" {
  listener_arn = aws_alb_listener.api-https.arn
  priority     = 69

  action {
    type             = "forward"
    target_group_arn = data.aws_alb_target_group.tracking_k8s.arn
  }

  condition {
    path_pattern {
      values = [
      "/api/v2/orders/*"]
    }
  }
}

resource "aws_alb_listener_rule" "consumer-notify-prefs1-1-rule-https" {
  listener_arn = aws_alb_listener.api-https.arn
  priority     = 130

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.consumer_notify_prefs_external.arn
  }

  condition {
    path_pattern {
      values = [
      "/api/v1.1/notify-preferences/*"]
    }
  }
}

resource "aws_route53_record" "ws" {
  zone_id = var.zone_id
  name    = "ws-${local.vpc_shortname}"
  type    = "A"
  alias {
    name                   = aws_alb.api.dns_name
    zone_id                = aws_alb.api.zone_id
    evaluate_target_health = false
  }
}

resource "aws_alb_listener_rule" "return-service-apis-rule-https" {
  listener_arn = aws_alb_listener.api-https.arn
  priority     = 140

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.return-service-apis.arn
  }

  condition {
    path_pattern {
      values = [
      "/api/v1/returns/*"]
    }
  }
}

resource "aws_alb_listener_rule" "inventory-rule-https" {
  listener_arn = aws_alb_listener.api-https.arn
  priority     = 160

  action {
    type             = "forward"
    target_group_arn = data.aws_alb_target_group.inventory_k8s.arn
  }

  condition {
    path_pattern {
      values = [
        "/api/v1/inventory",
      "/api/v1/inventory/*"]
    }
  }
}

resource "aws_security_group_rule" "eks_worker_ingress_api" {
  security_group_id        = data.aws_security_group.eks_worker.id
  source_security_group_id = aws_security_group.api-alb.id
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  type                     = "ingress"
}

resource "aws_security_group" "api-alb" {
  name        = "api-${local.vpc_name}-alb"
  description = "API ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  tags = {
    Name = "api-${local.vpc_name}-alb"
  }
}


data "aws_alb_target_group" "inventory_k8s" {
  name = "inventory-${local.vpc_shortname}-tg"
}

data "aws_alb_target_group" "tracking_k8s" {
  name = "tracking-api-${local.vpc_shortname}-tg"
}

data "aws_alb_target_group" "edd-checkout-api" {
  name = "edd-checkout-api-${local.vpc_shortname}"
}

data "aws_alb_target_group" "carrier-data-ingestion" {
  name = "carrier-data-ingestion-${local.vpc_shortname}-tg"
}

data "aws_alb_target_group" "messaging-action-api" {
  name = "messaging-action-api-${local.vpc_shortname}-tg"
}
