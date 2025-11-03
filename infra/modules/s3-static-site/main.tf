resource "aws_s3_bucket" "static_site" {
  bucket = var.bucket_name
  tags   = { Name = var.bucket_name }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.static_site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Mapeo de extensiones de archivo a tipos MIME
locals {
  mime_types = {
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"
    "json" = "application/json"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "jpeg" = "image/jpeg"
    "gif"  = "image/gif"
    "svg"  = "image/svg+xml"
    "ico"  = "image/x-icon"
  }
}

# Obtener la lista de archivos, excluyendo index.html
locals {
  website_files = fileset(var.website_source_path, "**/*.*")
  other_files   = toset([for f in local.website_files : f if f != "index.html"])
}

# Recurso para subir los otros archivos (no index.html)
resource "aws_s3_object" "website_other_files" {
  for_each = local.other_files

  bucket       = aws_s3_bucket.static_site.id
  key          = each.value
  source       = "${var.website_source_path}/${each.value}"
  content_type = lookup(local.mime_types, regex("\\.([a-zA-Z0-9]+)$", each.value)[0], "application/octet-stream")
  etag         = filemd5("${var.website_source_path}/${each.value}")
}

# Recurso para subir index.html, inyectando la URL de la API
resource "aws_s3_object" "website_index" {
  bucket       = aws_s3_bucket.static_site.id
  key          = "index.html"
  content_type = "text/html"
  content      = templatefile("${var.website_source_path}/index.html", { api_url = var.api_gateway_url })
  etag         = filemd5(templatefile("${var.website_source_path}/index.html", { api_url = var.api_gateway_url }))
}


output "bucket_domain_name" {
  description = "El nombre de dominio regional del bucket S3"
  value       = aws_s3_bucket.static_site.bucket_regional_domain_name
}

output "bucket_id" {
  description = "El ID (nombre) del bucket S3"
  value       = aws_s3_bucket.static_site.id
}

output "bucket_arn" {
  description = "El ARN del bucket S3"
  value       = aws_s3_bucket.static_site.arn
}