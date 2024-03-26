resource "aws_wafv2_ip_set" "tracking-nginx-waf-ipset" {
  name               = "tracking-nginx-waf-ipset-${local.vpc_shortname}"
  description        = "tracking-nginx-waf-ipset-${local.vpc_shortname}"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["34.238.247.27/32", "3.92.209.131/32", "3.92.211.160/32", "52.207.133.36/32"]

  tags = {
    Name = "Tracking Nginx IPSet"
  }
}

# See: https://github.com/hashicorp/terraform-provider-aws/issues/19727
resource "aws_wafv2_web_acl" "tracking-nginx-waf-acl" {
  name        = "tracking-nginx-waf-acl-${local.vpc_shortname}"
  description = "tracking-nginx-waf-acl-${local.vpc_shortname}"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "ip-rule-block"
    priority = 1

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.tracking-nginx-waf-ipset.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "TrackingNginxMatch-IPMatch-${local.vpc_shortname}"
      sampled_requests_enabled   = false
    }
  }

  tags = {
    Name = "tracking-nginx-match-rule"
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "TrackingNginxMatch-${local.vpc_shortname}"
    sampled_requests_enabled   = false
  }
}


output "tracking-nginx_web-acl-id-v2" {
  value = aws_wafv2_web_acl.tracking-nginx-waf-acl.id
}