# Care Cloudfront
resource "aws_cloudfront_origin_access_identity" "care" {
  comment = "care-${local.vpc_shortname}"
}

resource "aws_cloudfront_distribution" "care" {
  aliases = ["care-${local.vpc_shortname}.${var.domain}", "care-${local.vpc_shortname}-gamestop.${var.domain}"]
  enabled = true

  origin {
    domain_name = aws_alb.care.dns_name
    origin_id   = "ELB-${element(split(".", aws_alb.care.dns_name), 0)}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "ELB-${element(split(".", aws_alb.care.dns_name), 0)}"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern           = "/static/*"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "ELB-${element(split(".", aws_alb.care.dns_name), 0)}"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = true
      headers      = ["host", "origin"]

      cookies {
        forward = "all"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.ssl_certificate_arn_us_east_1
    minimum_protocol_version       = "TLSv1.2_2018"
    ssl_support_method             = "sni-only"
  }
}

resource "aws_route53_record" "care" {
  zone_id = var.zone_id
  name    = "care-${local.vpc_shortname}"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.care.domain_name
    zone_id                = aws_cloudfront_distribution.care.hosted_zone_id
    evaluate_target_health = false
  }
}