variable "origin_bucket" {
  type        = string
  description = "Dominio del bucket S3 que actúa como origen"
}

variable "distribution_name" {
  type        = string
  description = "Nombre identificador para la distribución CloudFront"
  default     = "cdn-distribution"
}

variable "price_class" {
  type        = string
  description = "Rango de regiones donde se distribuye el contenido (PriceClass_100, 200, All)"
  default     = "PriceClass_100"
}

variable "environment" {
  type        = string
  description = "Nombre del entorno (dev, staging, prod)"
  default     = "dev"
}
