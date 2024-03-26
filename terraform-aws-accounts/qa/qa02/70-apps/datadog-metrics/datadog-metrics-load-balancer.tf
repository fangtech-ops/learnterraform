resource "aws_lb" "datadog-metrics" {
  name               = "datadog-metrics-${local.vpc_shortname}"
  subnets            = split(",", var.public_subnets)
  internal           = true
  load_balancer_type = "network"

  tags = {
    Name    = "datadog_metrics-${local.vpc_shortname}"
    app     = "datadog_metrics"
    cluster = local.vpc_shortname
    stack   = local.vpc_name
    sku     = "devops"
  }
}

resource "aws_lb_target_group" "datadog-metrics" {
  name                 = "datadog-metrics-${local.vpc_shortname}"
  port                 = 8125
  protocol             = "UDP"
  vpc_id               = var.vpc_id
  deregistration_delay = 0
  health_check {
    port     = "5555"
    protocol = "TCP"
  }
  tags = {
    Name  = "datadog-metrics-${local.vpc_shortname}"
    app   = "datadog-metrics"
    stack = local.vpc_name
    sku   = "devops"
  }
}

resource "aws_lb_listener" "datadog-metrics" {
  load_balancer_arn = aws_lb.datadog-metrics.arn
  port              = "8125"
  protocol          = "UDP"

  default_action {
    target_group_arn = aws_lb_target_group.datadog-metrics.arn
    type             = "forward"
  }
}

resource "aws_route53_record" "datadog-metrics-internal" {
  zone_id = var.zone_id_internal
  name    = "datadog-metrics"
  type    = "A"
  alias {
    name                   = aws_lb.datadog-metrics.dns_name
    zone_id                = aws_lb.datadog-metrics.zone_id
    evaluate_target_health = false
  }
}

resource "aws_security_group" "datadog-metrics-nlb" {
  name        = "datadog-metrics-${local.vpc_name}-nlb"
  description = "Datadog Metrics NLB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 8125
    to_port   = 8125
    protocol  = "udp"
    cidr_blocks = [
    "${local.vpc_cidr}"]
  }

  ingress {
    from_port = 5555
    to_port   = 5555
    protocol  = "tcp"
    cidr_blocks = [
    "${local.vpc_cidr}"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "${local.vpc_cidr}"]
  }

  tags = {
    Name = "datadog_metrics-${local.vpc_name}-nlb"
  }
}
