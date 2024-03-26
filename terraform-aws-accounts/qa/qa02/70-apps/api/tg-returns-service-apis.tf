resource "aws_alb_target_group" "return-service-apis" {
  name                 = "return-service-apis-${local.vpc_shortname}"
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
    Name  = "return-service-apis-${local.vpc_shortname}"
    app   = "return-service-apis"
    stack = local.vpc_name
  }
}

resource "aws_security_group" "return-service-apis-redis" {
  name        = "return-service-apis-redis-${local.vpc_name}"
  description = "Return service apis redis Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"
    security_groups = [
      var.bastion_group_id,
      data.aws_security_group.eks_worker.id,
      aws_security_group.return-service-apis.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "return-service-apis-redis-${local.vpc_name}"
  }
}

resource "aws_elasticache_cluster" "return-service-apis" {
  cluster_id           = "return-service-apis-${local.vpc_shortname}"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  # engine_version = "6.0.5"
  engine_version = "6.x" # https://stackoverflow.com/questions/70916269/engine-version-redis-versions-must-match-major-x-when-using-version-6-or-high
  port           = 6379
  security_group_ids = [
  aws_security_group.return-service-apis-redis.id]
  subnet_group_name = "elasticache-subnet-group-qa02"
}

resource "aws_route53_record" "return-service-apis-redis" {

  name    = "return-service-apis-redis"
  zone_id = var.zone_id_internal
  type    = "CNAME"
  ttl     = 300
  records = [
  aws_elasticache_cluster.return-service-apis.cache_nodes[0].address]
}

resource "aws_security_group" "return-service-apis" {
  name        = "return-service-apis-${local.vpc_name}"
  description = "Return Service Apis Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    security_groups = [
      data.aws_security_group.api-alb.id
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
    Name = "return_service_apis-${local.vpc_name}"
  }
}

