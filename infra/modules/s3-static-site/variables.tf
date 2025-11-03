variable "bucket_name" {
  type        = string
  description = "Nombre del bucket para sitio estático"
}

variable "website_source_path" {
  type        = string
  description = "Ruta a la carpeta con los archivos del sitio web estático"
}

variable "api_gateway_url" {
  type        = string
  description = "URL del API Gateway para inyectar en el frontend"
  default     = ""
}

variable "cognito_user_pool_id" {
  type        = string
  description = "ID del User Pool de Cognito para el frontend"
}

variable "cognito_app_client_id" {
  type        = string
  description = "ID del App Client de Cognito para el frontend"
}

