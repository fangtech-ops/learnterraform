resource "aws_security_group" "returns_rules_lambdas" {
  name        = "returns_rules_lambdas-${local.vpc_name}"
  description = "Returns Rules Lambdas Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    security_groups = [
      var.bastion_group_id,
      aws_security_group.returns-front.id,
      aws_security_group.returns-back.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "returns_rules_lambdas-${local.vpc_name}"
  }
}

// API Gateway Routes
resource "aws_api_gateway_resource" "returns_rules" {
  rest_api_id = data.aws_api_gateway_rest_api.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1.id
  path_part   = "returns-rules"
}

resource "aws_api_gateway_method" "returns_rules" {
  rest_api_id   = data.aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.returns_rules.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "returns_rules" {
  rest_api_id             = data.aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.returns_rules.id
  http_method             = aws_api_gateway_method.returns_rules.http_method
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.qa_returns_rules_arn}/invocations"
  integration_http_method = "POST"
}

# Integration Response
resource "aws_api_gateway_integration_response" "returns_rules" {
  rest_api_id = data.aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.returns_rules.id
  http_method = aws_api_gateway_method.returns_rules.http_method
  status_code = aws_api_gateway_method_response.returns_rules.status_code
}

# Method 200 Response
resource "aws_api_gateway_method_response" "returns_rules" {
  rest_api_id = data.aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.returns_rules.id
  http_method = aws_api_gateway_method.returns_rules.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_lambda_permission" "returns_rules_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.qa_returns_rules_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${local.account_id}:${data.aws_api_gateway_rest_api.api_gateway.id}/*/${aws_api_gateway_method.returns_rules.http_method}${aws_api_gateway_resource.returns_rules.path}"
}

resource "aws_api_gateway_deployment" "returns_rules" {
  depends_on = [
    aws_api_gateway_method.returns_rules,
    aws_api_gateway_integration.returns_rules,
  ]
  rest_api_id = data.aws_api_gateway_rest_api.api_gateway.id
  stage_name  = local.vpc_shortname
}

resource "aws_route53_record" "returns_rules" {
  zone_id = var.zone_id_internal
  name    = "returns-rules"
  type    = "CNAME"
  ttl     = 60
  records = ["${data.aws_api_gateway_rest_api.api_gateway.id}.execute-api.${var.aws_region}.amazonaws.com"]
}

