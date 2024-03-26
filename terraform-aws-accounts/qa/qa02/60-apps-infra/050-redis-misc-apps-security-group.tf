# # The (bare minimum) AWS Redis (ElastiCache) resource was manually created.
# # Terraform (here) is used to create things on top of the (existing) Redis.
# resource "aws_elasticache_cluster" "..." {
#   ...
# }

resource "aws_elasticache_subnet_group" "default" {
  name       = "elasticache-subnet-group-${local.vpc_shortname}"
  subnet_ids = split(",", var.private_subnets)
}

resource "aws_security_group" "assistredis" {
  name        = "assistredis-${local.vpc_name}"
  description = "Assist redis Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"
    security_groups = [
      var.bastion_group_id,
      data.aws_security_group.assist.id,
      data.aws_security_group.tracking-back.id,
      data.aws_security_group.eks_worker.id,
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
    Name = "assistredis-${local.vpc_name}"
  }
}

resource "aws_security_group" "narvarappsredis" {
  name        = "narvarappsredis-${local.vpc_name}"
  description = "Narvarapps redis Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"
    security_groups = [
      var.bastion_group_id,
      data.aws_security_group.tracking-api.id,
      data.aws_security_group.tracking-back.id,
      data.aws_security_group.returns-back.id,
      data.aws_security_group.returns-front.id,
      data.aws_security_group.edd-checkout-api.id,
      data.aws_security_group.orders-api.id,
      aws_security_group.comms_lambda.id,
      data.aws_security_group.eks_worker.id,

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
    Name = "narvarappsredis-${local.vpc_name}"
  }
}

resource "aws_security_group" "quartzredis" {
  name        = "quartzredis-${local.vpc_name}"
  description = "Quartz redis Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"
    security_groups = [
      var.bastion_group_id,
      data.aws_security_group.tracking-back.id,
      data.aws_security_group.quartz_trigger.id,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  tags = {
    Name = "quartzredis-${local.vpc_name}"
  }
}

resource "aws_security_group" "content_api_redis" {
  name        = "content_api_redis-${local.vpc_name}"
  description = "Content API redis Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"
    security_groups = [
      var.bastion_group_id,
      data.aws_security_group.content_api.id,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  tags = {
    Name = "content_api_redis-${local.vpc_name}"
  }
}

resource "aws_security_group" "assist_cache_redis" {
  name        = "assist_cache_redis-${local.vpc_name}"
  description = "Assist Cache redis Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"
    security_groups = [
      data.aws_security_group.template_processor_internal.id,
      var.bastion_group_id,
      #aws_security_group.assist_cache.id,
      data.aws_security_group.content_api.id,
      data.aws_security_group.eks_worker.id,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  tags = {
    Name = "assist_cache_redis-${local.vpc_name}"
  }
}

resource "aws_security_group" "carrier_api_facade_redis" {
  name        = "carrier_api_facade_redis-${local.vpc_name}"
  description = "Carrier api facade  redis Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 6379
    to_port   = 6379
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
    Name = "carrier_api_facade_redis-${local.vpc_name}"
  }
}
