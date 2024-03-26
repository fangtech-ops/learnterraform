// API GATEWAY
resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "api-${local.vpc_shortname}"
  description = "API Gateway for Notification Time Service Lambda"
}

resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "v1" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "v1"
}

