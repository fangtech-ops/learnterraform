resource "aws_elasticache_cluster" "webhook-taskhandler" {
  cluster_id           = "webhook-th-${local.vpc_shortname}"
  engine               = "redis"
  node_type            = "cache.t2.small"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.6"
  port                 = 6379
  security_group_ids = [
  aws_security_group.webhook-taskhandler-redis.id]
  subnet_group_name = "elasticache-subnet-group-qa02"
}

resource "aws_route53_record" "webhook-taskhandler-redis" {
  name    = "webhook-taskhandler-redis"
  zone_id = var.zone_id_internal
  type    = "CNAME"
  ttl     = 300
  records = [
    aws_elasticache_cluster.webhook-taskhandler.cache_nodes[0].address
  ]
}

resource "aws_security_group" "webhook-taskhandler-redis" {
  name        = "webhook-taskhandler-redis-${local.vpc_name}"
  description = "Webhook Taskhandler redis Security Group"
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
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "webhook-taskhandler-redis-${local.vpc_name}"
  }
}
