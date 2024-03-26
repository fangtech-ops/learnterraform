# Migrated from:
#   - https://github.com/narvar/DevOps/blob/2997edf1415fd3d26efb779d9f9e39e263c20954/terraform/stacks/qa02_uswest2/comms_lambda.tf#L1-L16
#
# The notification_time api gateway resources are moved to:
#   - 70-apps/notification-time/*.tf


resource "aws_security_group" "comms_lambda" {
  name        = "comms_lambda-${local.vpc_name}-alb"
  description = "Comms Lambda Security Group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "comms_lambda-${local.vpc_name}-elb"
  }
}
