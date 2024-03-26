resource "aws_security_group" "vault" {
  name        = "vault-${local.vpc_name}"
  description = "Vault Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description      = "ingress-rule-1"
    cidr_blocks      = [
        local.vpc_cidr,
      ]
    from_port        = 8200
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 8200
  }

  ingress {
    description      = "ingress-rule-2"
    cidr_blocks      = [
        local.vpc_cidr,
      ]
    from_port        = 8201
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 8201
  }

  ingress {
    description      = "ingress-rule-3"
    from_port        = 8200
    to_port          = 8200
    protocol         = "tcp"
    security_groups  = [
      aws_security_group.vault-elb.id,
    ]
  }

  ingress {
    description      = "ingress-rule-4"
    from_port        = 8201
    to_port          = 8201
    protocol         = "tcp"
    security_groups  = [
      aws_security_group.vault-elb.id,
    ]
  }

  egress {
    description = "egress-rule-4"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vault-${local.vpc_name}"
  }
}

resource "aws_security_group" "vault-elb" {
  name        = "vault-${local.vpc_name}-elb"
  description = "Vault ELB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 8200
    to_port   = 8201
    protocol  = "tcp"
    cidr_blocks = [
      local.vpc_cidr,
      var.qa01_vpc_cidr,
      var.st01_vpc_cidr,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vault-${local.vpc_name}-elb"
  }
}

resource "aws_elb" "vault" {
  name            = "vault-${local.vpc_shortname}"
  subnets         = split(",", var.private_subnets)
  internal        = true
  security_groups = [aws_security_group.vault-elb.id]

  cross_zone_load_balancing = true
  idle_timeout              = 60
  connection_draining       = false

  listener {
    lb_protocol       = "TCP"
    lb_port           = 8200
    instance_protocol = "TCP"
    instance_port     = 8200
  }

  listener {
    lb_protocol       = "TCP"
    lb_port           = 8201
    instance_protocol = "TCP"
    instance_port     = 8201
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 10
    target              = "https:8200/v1/sys/health"
  }

  tags = {
    Name    = "vault-${local.vpc_shortname}"
    app     = "vault"
    cluster = local.vpc_shortname
    stack = local.vpc_shortname
}
}

resource "aws_security_group" "rds-vault" {
  name        = "rds-vault-${local.vpc_name}"
  description = "Vault MySQL Database Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    security_groups = [
      aws_security_group.vault.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-vault-${local.vpc_name}"
  }
}

resource "aws_route53_record" "vault" {
  zone_id = var.zone_id
  name    = "vault-${local.vpc_shortname}"
  type    = "A"
  alias {
    name                   = aws_elb.vault.dns_name
    zone_id                = aws_elb.vault.zone_id
    evaluate_target_health = false
  }
}

