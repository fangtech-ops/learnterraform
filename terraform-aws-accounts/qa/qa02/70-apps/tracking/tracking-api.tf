resource "aws_security_group" "tracking-api" {
  name        = "tracking_api-${local.vpc_name}"
  description = "Tracking API Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    security_groups = [
      data.aws_security_group.api-alb.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tracking_api-${local.vpc_name}"
  }
}

# data "aws_alb_target_group" "tracking_k8s" {
#   name = "tracking-api-${var.vpc_shortname}-tg"
# }
