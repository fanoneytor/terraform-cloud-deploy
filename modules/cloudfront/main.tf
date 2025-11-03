resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = var.origin_bucket
    origin_id   = "S3-Origin"
  }

  default_cache_behavior {
    target_origin_id       = "S3-Origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = var.distribution_name
    Environment = var.environment
  }
}

output "cdn_domain_name" {
  description = "Dominio público del CDN CloudFront"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "cdn_id" {
  description = "ID interno de la distribución CloudFront"
  value       = aws_cloudfront_distribution.cdn.id
}
