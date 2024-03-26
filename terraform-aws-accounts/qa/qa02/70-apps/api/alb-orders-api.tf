resource "aws_alb" "orders-api-int" {
  name            = "orders-api-int-${local.vpc_shortname}"
  subnets         = split(",", var.private_subnets)
  internal        = true
  security_groups = [aws_security_group.orders-api-int-alb.id]

  tags = {
    Name    = "orders-api-int-${local.vpc_shortname}"
    app     = "orders-api-int"
    cluster = local.vpc_shortname
    stack   = local.vpc_shortname
    sku     = "data-services"
  }
}

resource "aws_alb_target_group" "orders-api" {
  name                 = "orders-api-${local.vpc_shortname}"
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
  tags = {
    Name  = "orders_api-${local.vpc_shortname}"
    app   = "orders_api"
    stack = local.vpc_name
    sku   = "data-services"
  }

}

resource "aws_security_group" "orders-api-int-alb" {
  name        = "orders-api-int-${local.vpc_name}-alb"
  description = "Orders API Internal ALB Security Group"
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
    Name = "orders-api-int-${local.vpc_name}-alb"
  }
}

resource "aws_alb_target_group" "orders-api-int" {
  name                 = "orders-api-int-${local.vpc_shortname}"
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
  tags = {
    Name  = "orders-api-int-${local.vpc_shortname}"
    app   = "orders-api-int"
    stack = local.vpc_name
    sku   = "data-services"
  }
}

resource "aws_alb_listener" "orders-api-int-http" {
  load_balancer_arn = aws_alb.orders-api-int.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.orders-api-int.arn
    type             = "forward"
  }
}

#resource "aws_route53_record" "orders-api-int" {
#  zone_id = var.zone_id_internal
#  name    = "orders-api"
#  type    = "A"
#  alias {
#    name                   = aws_alb.orders-api-int.dns_name
#    zone_id                = aws_alb.orders-api-int.zone_id
#    evaluate_target_health = false
#  }
#}

resource "aws_security_group" "orders-api" {
  name        = "orders_api-${local.vpc_name}"
  description = "Orders API Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    security_groups = [
      data.aws_security_group.api-alb.id,
      data.aws_security_group.healthcheck-alb.id,
      aws_security_group.orders-api-int-alb.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "orders_api-${local.vpc_name}"
  }
}

resource "aws_iam_role" "orders-api" {
  name               = "app-orders-api-${local.vpc_shortname}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}


