output "cdn_url" {
  description = "URL accesible de la distribución"
  value       = aws_cloudfront_distribution.cdn.domain_name
}
