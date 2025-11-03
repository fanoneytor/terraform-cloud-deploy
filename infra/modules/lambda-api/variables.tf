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

variable "pre_signup_lambda_source_path" {
  type        = string
  description = "Ruta a la carpeta con el código fuente de la función Lambda de pre-registro de Cognito"
  default     = ""
}