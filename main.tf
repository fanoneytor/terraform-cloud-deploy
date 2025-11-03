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
  source      = "./modules/s3-static-site"
  bucket_name = var.bucket_name
}

module "cloudfront" {
  source        = "./modules/cloudfront"
  origin_bucket = module.s3_static_site.bucket_domain_name
}

module "lambda_api" {
  source     = "./modules/lambda-api"
  lambda_zip = var.lambda_zip
}

module "dynamodb" {
  source     = "./modules/dynamodb"
  table_name = var.dynamodb_table_name
}

module "route53" {
  source      = "./modules/route53"
  domain_name = var.domain_name
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
}
