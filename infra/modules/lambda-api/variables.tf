variable "lambda_source_path" {
  type        = string
  description = "Ruta a la carpeta con el código fuente de la función Lambda"
}

variable "dynamodb_table_name" {
  type        = string
  description = "Nombre de la tabla DynamoDB"
}

variable "dynamodb_table_arn" {
  type        = string
  description = "ARN de la tabla DynamoDB"
}

variable "cognito_user_pool_arn" {
  type        = string
  description = "ARN del User Pool de Cognito para el autorizador de la API"
}

variable "cognito_app_client_id" {
  type        = string
  description = "ID del App Client de Cognito para la audiencia del autorizador"
}

