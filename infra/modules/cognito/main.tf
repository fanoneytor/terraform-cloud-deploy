resource "aws_cognito_user_pool" "main" {
  name = var.user_pool_name

  auto_verified_attributes = ["email"]

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    required                 = true
    mutable                  = true
  }

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  # Permite que los usuarios se registren por sí mismos
  admin_create_user_config {
    allow_admin_create_user_only = false
  }
}

resource "aws_cognito_user_pool_client" "main" {
  name = var.app_client_name
  user_pool_id = aws_cognito_user_pool.main.id

  # Habilita el flujo de autenticación necesario para el SDK de JS
  explicit_auth_flows = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  
  # No generar un secreto de cliente, ya que es una app pública de frontend
  generate_secret = false
}
