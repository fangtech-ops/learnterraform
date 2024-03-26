resource "aws_security_group" "order_email_scraper_lambda" {
  name        = "order_email_scraper_lambda-${local.vpc_name}"
  description = "Email scraper Lambda Security Group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "order_email_scraper_lambda-${local.vpc_name}"
  }
}

