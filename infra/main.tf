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

# --- Módulos de la Aplicación ---

module "cognito" {
  source = "./modules/cognito"
  # Usamos el nombre del bucket como prefijo para el nombre del pool
  user_pool_name = "${var.bucket_name}-user-pool"
  pre_signup_lambda_arn = module.lambda_api.pre_signup_lambda_arn
}

module "s3_static_site" {
  source                = "./modules/s3-static-site"
  bucket_name           = var.bucket_name
  website_source_path   = "${path.module}/../src/frontend"
  api_gateway_url       = module.lambda_api.api_url
  cognito_user_pool_id  = module.cognito.user_pool_id
  cognito_app_client_id = module.cognito.app_client_id
}

module "dynamodb" {
  source     = "./modules/dynamodb"
  table_name = var.dynamodb_table_name
}

module "lambda_api" {
  source                = "./modules/lambda-api"
  lambda_source_path    = "${path.module}/../src/backend"
  pre_signup_lambda_source_path = "${path.module}/../src/backend"
  dynamodb_table_name   = module.dynamodb.table_name
  dynamodb_table_arn    = module.dynamodb.table_arn
  cloudfront_url        = module.cloudfront.cdn_url
}

module "api-gateway-auth" {
  source                = "./modules/api-gateway-auth"
  api_id                = module.lambda_api.api_id
  lambda_integration_id = module.lambda_api.lambda_integration_id
  cognito_app_client_id = module.cognito.app_client_id
  cognito_user_pool_id  = module.cognito.user_pool_id
  aws_region            = var.aws_region
}

# --- Módulos de Red y DNS ---

module "cloudfront" {
  source            = "./modules/cloudfront"
  origin_bucket     = module.s3_static_site.bucket_domain_name
  origin_bucket_id  = module.s3_static_site.bucket_id
  origin_bucket_arn = module.s3_static_site.bucket_arn
  distribution_name = var.bucket_name
}

module "route53" {
  source      = "./modules/route53"
  domain_name = var.domain_name
}