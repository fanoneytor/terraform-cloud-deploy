variable "api_id" {
  description = "ID of the API Gateway"
  type        = string
}

variable "cognito_app_client_id" {
  description = "Cognito App Client ID"
  type        = string
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "lambda_integration_id" {
  description = "ID of the Lambda integration"
  type        = string
}