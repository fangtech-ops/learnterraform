resource "aws_cloudwatch_event_rule" "exception-sql-poller-trigger" {
  name                = "exception-sql-poller-trigger-${local.vpc_shortname}"
  description         = "Triggers the exception-order_ndr_data_push lambda to check SQS statuses."
  schedule_expression = "rate(1 minute)"
  role_arn            = var.qa_exception_lambda_role_arn
}

resource "aws_cloudwatch_event_target" "exception-sql-poller-trigger" {
  target_id = "exception-sql-poller-trigger-${local.vpc_shortname}"
  rule      = aws_cloudwatch_event_rule.exception-sql-poller-trigger.name
  arn       = var.qa_exception_order_ndr_data_push_arn
}

/*resource "aws_lambda_permission" "exception-sql-poller-trigger" {
  statement_id  = "AllowExecutionFromCloudWatchSqlPoller"
  action        = "lambda:InvokeFunction"
  function_name = var.qa_exception_order_ndr_data_push_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.exception-sql-poller-trigger.arn
}

*/

resource "aws_cloudwatch_event_rule" "exception-callback-tracking-trigger" {
  name                = "exception-callback-tracking-trigger-${local.vpc_shortname}"
  description         = "Triggers the exception-callbacks_tracking-push-queue-processor  lambda to check SQS statuses."
  schedule_expression = "rate(1 minute)"
  role_arn            = var.qa_exception_lambda_role_arn
}

resource "aws_cloudwatch_event_target" "exception-callback-tracking-trigger" {
  target_id = "exception-callback-tracking-trigger-${local.vpc_shortname}"
  rule      = aws_cloudwatch_event_rule.exception-callback-tracking-trigger.name
  arn       = var.qa_exception_callbacks_tracking_push_queue_processor
}

resource "aws_lambda_permission" "exception-callback-tracking-trigger" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = var.qa_exception_callbacks_tracking_push_queue_processor
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.exception-callback-tracking-trigger.arn
}

