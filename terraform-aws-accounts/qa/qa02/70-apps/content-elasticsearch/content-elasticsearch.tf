resource "aws_security_group" "content-api-es" {
  name        = "content-api-es-${local.vpc_name}"
  description = "content-api-es Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    security_groups = [
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
    Name = "content-api-es-${local.vpc_name}"
  }
}

resource "aws_elasticsearch_domain" "content-api" {
  domain_name           = "content-api-${local.vpc_shortname}"
  elasticsearch_version = "6.0"

  // Encryption at rest is not supported for instance types t2
  // encrypt_at_rest = true
  node_to_node_encryption {
    enabled = true
  }

  cluster_config {
    instance_type            = "t2.small.elasticsearch"
    instance_count           = 2
    dedicated_master_enabled = false
    zone_awareness_enabled   = true
    // dedicated_master_count = 3
    // dedicated_master_type = "t2.small.elasticsearch"
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  vpc_options {
    subnet_ids         = flatten([[element(split(",", var.private_subnets), 0)], [element(split(",", var.private_subnets), 1)]])
    security_group_ids = [aws_security_group.content-api-es.id]
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "*"
        ]
      },
      "Action": [
        "es:*"
      ],
      "Resource": "*"
    }
  ]
}
CONFIG


  tags = {
    Domain = "content-api"
  }
}

resource "aws_route53_record" "content-api" {
  zone_id = var.zone_id_internal
  name    = "es-content-api"
  type    = "CNAME"
  ttl     = 60
  records = [aws_elasticsearch_domain.content-api.endpoint]
}
