output "website_url" {
  description = "La URL HTTPS del sitio web estático servido por CloudFront."
  value       = "https://${module.cloudfront.cdn_url}"
}

output "api_gateway_url" {
  description = "La URL base de la API Gateway."
  value       = module.lambda_api.api_url
}

output "s3_bucket_name" {
  description = "Nombre del bucket S3 donde se alojan los archivos del sitio."
  value       = module.s3_static_site.bucket_id
}

output "cognito_user_pool_id" {
  description = "ID del User Pool de Cognito."
  value       = module.cognito.user_pool_id
}

output "cognito_app_client_id" {
  description = "ID del App Client de Cognito."
  value       = module.cognito.app_client_id
}
