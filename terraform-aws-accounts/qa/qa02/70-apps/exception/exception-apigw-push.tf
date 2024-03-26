resource "aws_api_gateway_rest_api" "exception_sql_push" {
  name        = "exception-sql-push-${local.vpc_shortname}"
  description = "API Gateway for Exception Sql Push"
}

resource "aws_api_gateway_resource" "exception_sql_push_carrier" {
  rest_api_id = aws_api_gateway_rest_api.exception_sql_push.id
  parent_id   = aws_api_gateway_rest_api.exception_sql_push.root_resource_id
  path_part   = "{carrier}"
}

resource "aws_api_gateway_method" "exception_sql_push_carrier" {
  rest_api_id   = aws_api_gateway_rest_api.exception_sql_push.id
  resource_id   = aws_api_gateway_resource.exception_sql_push_carrier.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "exception_sql_push_carrier" {
  rest_api_id = aws_api_gateway_rest_api.exception_sql_push.id
  resource_id = aws_api_gateway_resource.exception_sql_push_carrier.id
  http_method = aws_api_gateway_method.exception_sql_push_carrier.http_method
  type        = "AWS"
  credentials = var.qa_exception_lambda_role_arn
  uri         = "arn:aws:apigateway:${var.aws_region}:sqs:path/${local.account_id}/${aws_sqs_queue.exception_tracking_push.name}"
  request_templates = {
    "application/json" = <<EOF
Action=SendMessage&MessageBody=$util.urlEncode($util.escapeJavaScript(
{
    "carrier":"'$input.params('carrier')'",
    "payload": "'$util.base64Encode($input.json('$'))'"
}
))
EOF

  }
  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }
  passthrough_behavior    = "NEVER"
  integration_http_method = "POST"
}

resource "aws_api_gateway_method_response" "exception_sql_push_carrier" {
  rest_api_id = aws_api_gateway_rest_api.exception_sql_push.id
  resource_id = aws_api_gateway_resource.exception_sql_push_carrier.id
  http_method = aws_api_gateway_method.exception_sql_push_carrier.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "exception_sql_push_carrier" {
  rest_api_id       = aws_api_gateway_rest_api.exception_sql_push.id
  resource_id       = aws_api_gateway_resource.exception_sql_push_carrier.id
  http_method       = aws_api_gateway_method.exception_sql_push_carrier.http_method
  status_code       = aws_api_gateway_method_response.exception_sql_push_carrier.status_code
  selection_pattern = aws_api_gateway_method_response.exception_sql_push_carrier.status_code
  response_templates = {
    "application/json" = <<EOF
{
    "status_update_number" : "$input.path('$.SendMessageResponse.SendMessageResult.MessageId')",
    "status":true
}
EOF

  }
  depends_on = [aws_api_gateway_integration.exception_sql_push_carrier]
}

resource "aws_api_gateway_deployment" "exception_sql_push_carrier" {
  depends_on = [
    aws_api_gateway_method.exception_sql_push_carrier,
    aws_api_gateway_integration.exception_sql_push_carrier,
  ]
  rest_api_id = aws_api_gateway_rest_api.exception_sql_push.id
  stage_name  = local.vpc_shortname
}

resource "aws_api_gateway_resource" "exception_sql_push_retailer" {
  rest_api_id = aws_api_gateway_rest_api.exception_sql_push.id
  parent_id   = aws_api_gateway_resource.exception_sql_push_carrier.id
  path_part   = "{retailer}"
}

resource "aws_api_gateway_method" "exception_sql_push_retailer" {
  rest_api_id   = aws_api_gateway_rest_api.exception_sql_push.id
  resource_id   = aws_api_gateway_resource.exception_sql_push_retailer.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "exception_sql_push_retailer" {
  rest_api_id = aws_api_gateway_rest_api.exception_sql_push.id
  resource_id = aws_api_gateway_resource.exception_sql_push_retailer.id
  http_method = aws_api_gateway_method.exception_sql_push_retailer.http_method
  type        = "AWS"
  credentials = var.qa_exception_lambda_role_arn
  uri         = "arn:aws:apigateway:${var.aws_region}:sqs:path/${local.account_id}/${aws_sqs_queue.exception_tracking_push.name}"
  request_templates = {
    "application/json" = <<EOF
Action=SendMessage&MessageBody=$util.urlEncode($util.escapeJavaScript({

    "carrier":"'$input.params('carrier')'",
    "retailer":"'$input.params('retailer')'",
    "payload": "'$util.base64Encode($input.json('$'))'"
}
))
EOF

  }
  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }
  passthrough_behavior    = "NEVER"
  integration_http_method = "POST"
}

resource "aws_api_gateway_method_response" "exception_sql_push_retailer" {
  rest_api_id = aws_api_gateway_rest_api.exception_sql_push.id
  resource_id = aws_api_gateway_resource.exception_sql_push_retailer.id
  http_method = aws_api_gateway_method.exception_sql_push_retailer.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "exception_sql_push_retailer" {
  rest_api_id       = aws_api_gateway_rest_api.exception_sql_push.id
  resource_id       = aws_api_gateway_resource.exception_sql_push_retailer.id
  http_method       = aws_api_gateway_method.exception_sql_push_retailer.http_method
  status_code       = aws_api_gateway_method_response.exception_sql_push_retailer.status_code
  selection_pattern = aws_api_gateway_method_response.exception_sql_push_retailer.status_code
  response_templates = {
    "application/json" = <<EOF
##  See http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-mapping-template-reference.html
##  This template will pass through all parameters including path, querystring, header, stage variables, and context through to the integration endpoint via the body/payload
## #set($allParams = $input.params())
{
    "status_update_number" : "$input.path('$.SendMessageResponse.SendMessageResult.MessageId')",
    "status":true
}
EOF

  }
  depends_on = [aws_api_gateway_integration.exception_sql_push_retailer]
}

resource "aws_api_gateway_deployment" "exception_sql_push_retailer" {
  depends_on = [
    aws_api_gateway_method.exception_sql_push_retailer,
    aws_api_gateway_integration.exception_sql_push_retailer,
  ]
  rest_api_id = aws_api_gateway_rest_api.exception_sql_push.id
  stage_name  = local.vpc_shortname
}

resource "aws_api_gateway_domain_name" "exception_sql_push" {
  domain_name     = "expush-qa02.narvar.qa"
  certificate_arn = var.ssl_certificate_arn_us_east_1
}

resource "aws_api_gateway_base_path_mapping" "exception_sql_push" {
  api_id      = aws_api_gateway_rest_api.exception_sql_push.id
  domain_name = aws_api_gateway_domain_name.exception_sql_push.domain_name
}

resource "aws_route53_record" "exception_sql_push" {
  zone_id = var.zone_id
  name    = aws_api_gateway_domain_name.exception_sql_push.domain_name
  type    = "A"
  alias {
    name                   = aws_api_gateway_domain_name.exception_sql_push.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.exception_sql_push.cloudfront_zone_id
    evaluate_target_health = true
  }
}

