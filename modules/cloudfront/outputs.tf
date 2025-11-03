output "cdn_url" {
  description = "URL accesible de la distribución (nombre de dominio)"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "cdn_id" {
  description = "ID interno de la distribución CloudFront"
  value       = aws_cloudfront_distribution.cdn.id
}

output "cdn_arn" {
  description = "ARN de la distribución CloudFront"
  value       = aws_cloudfront_distribution.cdn.arn
}