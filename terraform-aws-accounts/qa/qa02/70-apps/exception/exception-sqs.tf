resource "aws_sqs_queue" "exception_sms_queue" {
  name                       = "exception_sms_queue_${local.vpc_shortname}"
  visibility_timeout_seconds = 120
}

resource "aws_sqs_queue" "exception_logger_exception" {
  name                       = "exception_logger_exception_${local.vpc_shortname}"
  visibility_timeout_seconds = 120
}

resource "aws_sqs_queue" "exception_order_place_dead_queue" {
  name                       = "exception_order_place_dead_queue_${local.vpc_shortname}"
  visibility_timeout_seconds = 2
}

resource "aws_sqs_queue" "exception_order_place_s3" {
  name                       = "exception_order_place_s3_${local.vpc_shortname}"
  visibility_timeout_seconds = 120
  redrive_policy             = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.exception_order_place_dead_queue.arn}\",\"maxReceiveCount\":15}"
}

resource "aws_sqs_queue" "exception_dialer_ndr" {
  name                       = "exception_dialer_ndr_${local.vpc_shortname}"
  visibility_timeout_seconds = 120
}

resource "aws_sqs_queue" "exception_tracking_push" {
  name                       = "exception_tracking_push_${local.vpc_shortname}"
  visibility_timeout_seconds = 120
  redrive_policy             = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.exception_tracking_push_dead.arn}\",\"maxReceiveCount\":15}"
}

resource "aws_sqs_queue" "exception_tracking_push_dead" {
  name                       = "exception_tracking_push_dead_${local.vpc_shortname}"
  visibility_timeout_seconds = 120
}

resource "aws_sqs_queue" "exception_reminder_dead" {
  name                       = "exception_reminder_dead_${local.vpc_shortname}"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 1209600
}

resource "aws_sqs_queue" "exception_reminder" {
  name                       = "exception_reminder_${local.vpc_shortname}"
  visibility_timeout_seconds = 120
  redrive_policy             = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.exception_reminder_dead.arn}\",\"maxReceiveCount\":15}"
}

