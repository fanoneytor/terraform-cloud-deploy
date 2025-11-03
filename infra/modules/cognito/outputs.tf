output "user_pool_id" {
  description = "ID del User Pool de Cognito"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "ARN del User Pool de Cognito"
  value       = aws_cognito_user_pool.main.arn
}

output "app_client_id" {
  description = "ID del App Client de Cognito"
  value       = aws_cognito_user_pool_client.main.id
}
