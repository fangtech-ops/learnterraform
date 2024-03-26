# Migrated from:
#   - https://github.com/narvar/DevOps/blob/2997edf1415fd3d26efb779d9f9e39e263c20954/terraform/stacks/qa02_uswest2/comms_lambda.tf#L18-L59
#
# The pre-migration resource "aws_security_group" "comms_lambda" is now in:
#   - 60-apps-infra/035-comms-lambda-security-group.tf

resource "aws_api_gateway_resource" "notification_time" {
  rest_api_id = data.aws_api_gateway_rest_api.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1.id
  path_part   = "notification-time"
}

resource "aws_api_gateway_method" "notification_time" {
  rest_api_id   = data.aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.notification_time.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "notification_time" {
  rest_api_id             = data.aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.notification_time.id
  http_method             = aws_api_gateway_method.notification_time.http_method
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.qa_notification_time_service_arn}/invocations"
  integration_http_method = "POST"
}

//resource "aws_lambda_permission" "notification_time_lambda_permission" {
//  statement_id  = "AllowExecutionFromAPIGateway"
//  action        = "lambda:InvokeFunction"
//  function_name = var.qa_notification_time_service_arn
//  principal     = "apigateway.amazonaws.com"
//
//  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
//  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.account_id}:${aws_api_gateway_rest_api.api_gateway.id}/*/${aws_api_gateway_method.notification_time.http_method}${aws_api_gateway_resource.notification_time.path}"
//}

resource "aws_api_gateway_deployment" "notification_time" {
  depends_on = [
    aws_api_gateway_method.notification_time,
    aws_api_gateway_integration.notification_time,
  ]
  rest_api_id = data.aws_api_gateway_rest_api.api_gateway.id
  stage_name  = local.vpc_shortname
}

