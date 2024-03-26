resource "aws_security_group" "bot_defender" {
  name        = "bot_defender-${local.vpc_name}"
  description = "Bot Defender Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description = ""
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "71.202.81.38/32",
      "54.214.161.140/32",
      ]
  }

  ingress {
    description = ""
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.101.0.0/16"]
  }

  ingress {
    description = ""
    from_port = 7443
    to_port   = 7443
    protocol  = "tcp"
    cidr_blocks = ["54.185.2.166/32"]
  }

  ingress {
    description = ""
    from_port = 9093
    to_port   = 9093
    protocol  = "tcp"
    cidr_blocks = ["54.185.2.166/32"]
  }

  ingress {
    description = ""
    from_port = 9094
    to_port   = 9094
    protocol  = "tcp"
    cidr_blocks = ["54.185.2.166/32"]
  }

  ingress {
    description = ""
    from_port = 9080
    to_port   = 9080
    protocol  = "tcp"
    cidr_blocks = ["54.185.2.166/32"]
  }

  ingress {
    description = ""
    from_port = 9100
    to_port   = 9100
    protocol  = "tcp"
    cidr_blocks = ["54.185.2.166/32"]
  }

  ingress {
    description = ""
    from_port = 9122
    to_port   = 9122
    protocol  = "tcp"
    cidr_blocks = ["54.185.2.166/32"]
  }

  egress {
    description = ""
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bot_defender-${local.vpc_name}"
  }
}

resource "aws_alb_target_group" "tracking-nginx-botdefender" {
  name                 = "tracking-nginx-botdefender-${local.vpc_shortname}"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 0

  health_check {
    interval            = 10
    port                = 80
    path                = "/.stealth-check"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = 200
  }

  tags = {
    Name    = "tracking-nginx-botdefender-${local.vpc_shortname}"
    app     = "tracking-nginx"
    cluster = local.vpc_shortname
    stack   = local.vpc_name
  }
}
