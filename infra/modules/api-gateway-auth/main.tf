resource "aws_apigatewayv2_authorizer" "cognito_auth" {
  api_id           = var.api_id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-authorizer"

  jwt_configuration {
    audience = [var.cognito_app_client_id]
    issuer   = "https://cognito-idp.${var.aws_region}.amazonaws.com/${var.cognito_user_pool_id}"
  }
}

resource "aws_apigatewayv2_route" "protected_routes" {
  for_each = toset(["POST /products", "PUT /products/{id}", "DELETE /products/{id}"])

  api_id    = var.api_id
  route_key = each.value
  target    = "integrations/${var.lambda_integration_id}"
  authorizer_id = aws_apigatewayv2_authorizer.cognito_auth.id
  authorization_type = "JWT"
}
