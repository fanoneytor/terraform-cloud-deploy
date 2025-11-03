variable "aws_region" { default = "us-east-1" }
variable "bucket_name" { default = "my-company-static-site" }

variable "dynamodb_table_name" { default = "app-data" }
variable "domain_name" {
  default     = "yourdomain.com" # ¡IMPORTANTE! Cambia esto a tu propio dominio o uno de prueba.
  description = "Dominio principal (ej: example.com)"
}
