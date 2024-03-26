# # The (bare minimum) AWS RDS resource was manually created.
# # Terraform (here) is used to create things on top of the (existing) RDS.
# resource "aws_db_instance" "..." {
#   ...
# }

data "aws_security_group" "action-api" {
  vpc_id = var.vpc_id
  name   = "action_api-${local.vpc_name}"
}

data "aws_security_group" "analytics-api" {
  vpc_id = var.vpc_id
  name   = "analytics_api-${local.vpc_name}"
}

data "aws_security_group" "pritunl" {
  vpc_id = var.vpc_id
  name   = "pritunl-${local.vpc_name}"
}

data "aws_security_group" "carrier_queue_processor" {
  vpc_id = var.vpc_id
  name   = "carrier_queue_processor-${local.vpc_name}"
}

data "aws_security_group" "order_queue_processor" {
  vpc_id = var.vpc_id
  name   = "order_queue_processor-${local.vpc_name}"
}

data "aws_security_group" "scheduler_queue_processor" {
  vpc_id = var.vpc_id
  name   = "scheduler_queue_processor-${local.vpc_name}"
}

data "aws_security_group" "rules_engine" {
  vpc_id = var.vpc_id
  name   = "rules_engine-${local.vpc_name}"
}

data "aws_security_group" "exception_lambdas" {
  vpc_id = var.vpc_id
  name   = "exception_lambdas-${local.vpc_name}"
}


resource "aws_db_subnet_group" "default" {
  name       = "db-subnet-group-${local.vpc_shortname}"
  subnet_ids = split(",", var.private_subnets)

  tags = {
    Name = local.vpc_name
  }
}

resource "aws_security_group" "narvarappsdb" {
  name        = "narvarappsdb-${local.vpc_name}"
  description = "Narvarapps database Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    security_groups = [
      var.bastion_group_id,
      data.aws_security_group.tracking-api.id,
      data.aws_security_group.tracking-back.id,
      data.aws_security_group.returns-front.id,
      data.aws_security_group.returns-back.id,
      data.aws_security_group.orders-api.id,
      data.aws_security_group.action-api.id,
      data.aws_security_group.edd-checkout-api.id,
      data.aws_security_group.order_queue_processor.id,
      data.aws_security_group.carrier_queue_processor.id,
      data.aws_security_group.scheduler_queue_processor.id,
      var.metabase_security_group_id,
      data.aws_security_group.consumer_notify_prefs.id,
      data.aws_security_group.rules_engine.id,
      aws_security_group.comms_lambda.id,
      data.aws_security_group.sleep_service.id,
      data.aws_security_group.analytics-api.id,
      data.aws_security_group.toran.id,
      data.aws_security_group.shopify.id,
      "sg-07928d7e", # jenkins-qa01
      data.aws_security_group.eks_worker.id,
      data.aws_security_group.return-service-apis.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "narvarappsdb-${local.vpc_name}"
  }
}

resource "aws_security_group" "rds-eventproc" {
  name        = "rds-eventproc-${local.vpc_name}"
  description = "Eventproc RDS Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      var.bastion_group_id
    ]
    cidr_blocks = [local.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-exception-${local.vpc_name}"
  }
}

resource "aws_security_group" "content_api_db" {
  name        = "content_api_db-${local.vpc_name}"
  description = "content_api_db database Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    security_groups = [
      var.bastion_group_id,
      data.aws_security_group.content_api.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "content_api_db-${local.vpc_name}"
  }
}

resource "aws_security_group" "locus_db" {
  name        = "locus_db-${local.vpc_name}"
  description = "locus database Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      var.bastion_group_id,
      data.aws_security_group.eks_worker.id,
    ] # kubernetes-worker
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "locus_db-${local.vpc_name}"
  }
}

resource "aws_security_group" "rds-exception" {
  name        = "rds-exception-${local.vpc_name}"
  description = "Exception RDS Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      var.bastion_group_id,
      data.aws_security_group.exception_lambdas.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-exception-${local.vpc_name}"
  }
}

resource "aws_security_group" "hydra_db" {
  name        = "hydra_db-${local.vpc_name}"
  description = "Hydra database Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    security_groups = [
      var.bastion_group_id,
      data.aws_security_group.eks_worker.id,
    ] # kubernetes-worker
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "hydra_db-${local.vpc_name}"
  }
}

resource "aws_security_group" "rds-retool" {
  name        = "rds-retool-${local.vpc_name}"
  description = "Retool RDS Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      var.bastion_group_id,
      data.aws_security_group.eks_worker.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-retool-${local.vpc_name}"
  }
}

resource "aws_security_group" "freighter_db" {
  name        = "freighter_db-${local.vpc_name}"
  description = "freighter database Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      var.bastion_group_id,
      data.aws_security_group.eks_worker.id,
    ] # kubernetes-worker
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "freighter_db-${local.vpc_name}"
  }
}

resource "aws_security_group" "rds-kong" {
  name        = "rds-kong-${local.vpc_name}"
  description = "Kong RDS Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      var.bastion_group_id,
      data.aws_security_group.eks_worker.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-kong-${local.vpc_name}"
  }
}

resource "aws_security_group" "messaging_db" {
  name        = "messaging_db-${local.vpc_name}"
  description = "Messaging database Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      var.bastion_group_id,
      data.aws_security_group.eks_worker.id,
      data.aws_security_group.assist.id,
      data.aws_security_group.template_processor_internal.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "messaging_db-${local.vpc_name}"
  }
}

resource "aws_security_group" "pii_shield_db" {
  name        = "pii_shield_db-${local.vpc_name}"
  description = "PII Shield database Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      var.bastion_group_id,
      data.aws_security_group.eks_worker.id,
      data.aws_security_group.pritunl.id
    ]
    cidr_blocks = [var.qa01_vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pii_shield_db-${local.vpc_name}"
  }
}

resource "aws_security_group" "bahamas_db" {
  name        = "bahamas_db-${local.vpc_name}"
  description = "Bahamas database Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      var.bastion_group_id,
      data.aws_security_group.eks_worker.id,
      data.aws_security_group.pritunl.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bahamas_db-${local.vpc_name}"
  }
}