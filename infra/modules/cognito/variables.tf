variable "user_pool_name" {
  description = "Nombre para el User Pool de Cognito"
  type        = string
  default     = "NetSolutionsUserPool"
}

variable "app_client_name" {
  description = "Nombre para el App Client del User Pool"
  type        = string
  default     = "netsolutions-app-client"
}

variable "pre_signup_lambda_arn" {
  description = "ARN de la función Lambda de pre-registro de Cognito"
  type        = string
  default     = null
}
