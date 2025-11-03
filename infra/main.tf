terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- Módulos ---
module "s3_static_site" {
  source              = "./modules/s3-static-site"
  bucket_name         = var.bucket_name
  website_source_path = "${path.root}/frontend"
  api_gateway_url     = module.lambda_api.api_url
}

module "dynamodb" {
  source     = "./modules/dynamodb"
  table_name = var.dynamodb_table_name
}

module "lambda_api" {
  source              = "./modules/lambda-api"
  lambda_source_path  = "${path.module}/../src/backend"
  dynamodb_table_name = module.dynamodb.table_name
  dynamodb_table_arn  = module.dynamodb.table_arn
}

module "cloudfront" {
  source             = "./modules/cloudfront"
  origin_bucket      = module.s3_static_site.bucket_domain_name
  origin_bucket_id   = module.s3_static_site.bucket_id
  origin_bucket_arn  = module.s3_static_site.bucket_arn
  distribution_name  = var.bucket_name # Asignar un nombre a la distribución
}

module "route53" {
  source      = "./modules/route53"
  domain_name = var.domain_name
}
