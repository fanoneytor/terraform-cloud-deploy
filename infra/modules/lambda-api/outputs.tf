output "pre_signup_lambda_arn" {
  description = "ARN de la función Lambda de pre-registro de Cognito"
  value       = try(aws_lambda_function.pre_signup[0].arn, null)
}
