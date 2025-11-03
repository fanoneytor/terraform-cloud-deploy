variable "table_name" {
  type        = string
  description = "Nombre de la tabla DynamoDB"
}

variable "billing_mode" {
  type        = string
  description = "Modo de facturación (PROVISIONED o PAY_PER_REQUEST)"
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  type        = string
  description = "Clave primaria (partition key)"
  default     = "id"
}

variable "hash_key_type" {
  type        = string
  description = "Tipo de dato para la partition key (S, N, B)"
  default     = "S"
}

variable "sort_key" {
  type        = string
  description = "Clave de ordenamiento (sort key)"
  default     = null
}

variable "sort_key_type" {
  type        = string
  description = "Tipo de dato para la sort key (S, N, B)"
  default     = "S"
}

variable "ttl_enabled" {
  type        = bool
  description = "Habilita el tiempo de vida (TTL) para los ítems"
  default     = false
}

variable "ttl_attribute_name" {
  type        = string
  description = "Nombre del atributo TTL (si se usa)"
  default     = "ttl"
}

variable "environment" {
  type        = string
  description = "Entorno: dev, staging o prod"
  default     = "dev"
}
