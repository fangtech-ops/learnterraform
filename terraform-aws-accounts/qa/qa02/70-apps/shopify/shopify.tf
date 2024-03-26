resource "aws_security_group" "shopify-alb" {
  name = "shopify-${local.vpc_name}-alb"
  description = "Shopify ALB Security Group"
  vpc_id = var.vpc_id

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "shopify-${local.vpc_name}-alb"
  }
}

resource "aws_security_group" "shopify" {
  name = "shopify-${local.vpc_name}"
  description = "Shopify Security Group"
  vpc_id = var.vpc_id

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = [
      aws_security_group.shopify-alb.id,
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "shopify-${local.vpc_name}"
  }
}
