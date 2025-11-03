variable "lambda_function_name" {
  description = "Nombre de la función Lambda"
  type        = string
  default     = "backend-api"
}

variable "api_name" {
  description = "Nombre para el API Gateway"
  type        = string
  default     = "serverless-api"
}

# --- ROL Y POLÍTICAS DE IAM ---
resource "aws_iam_role" "lambda_exec" {
  name = "${var.lambda_function_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_policy" "main_policy" {
  name        = "${var.lambda_function_name}-main-policy"
  description = "Política de IAM para logs y acceso a DynamoDB para la función Lambda"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem", "dynamodb:DeleteItem", "dynamodb:Scan", "dynamodb:Query"],
        Effect   = "Allow",
        Resource = var.dynamodb_table_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "main_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.main_policy.arn
}

# --- FUNCIÓN LAMBDA ---
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.lambda_source_path
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "api" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name    = var.lambda_function_name
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  role             = aws_iam_role.lambda_exec.arn
  timeout          = 20

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.dynamodb_table_name
    }
  }
}

# --- ROL Y POLÍTICAS DE IAM PARA LAMBDA DE PRE-REGISTRO ---
resource "aws_iam_role" "pre_signup_lambda_exec" {
  name = "cognito-pre-signup-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_policy" "pre_signup_lambda_policy" {
  name        = "cognito-pre-signup-lambda-policy"
  description = "Política de IAM para logs de la función Lambda de pre-registro de Cognito"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "pre_signup_lambda_attachment" {
  role       = aws_iam_role.pre_signup_lambda_exec.name
  policy_arn = aws_iam_policy.pre_signup_lambda_policy.arn
}

# --- FUNCIÓN LAMBDA DE PRE-REGISTRO ---
data "archive_file" "pre_signup_lambda_zip" {
  type        = "zip"
  source_dir  = var.pre_signup_lambda_source_path
  output_path = "${path.module}/pre-signup-lambda.zip"
}

resource "aws_lambda_function" "pre_signup" {
  count            = var.pre_signup_lambda_source_path != "" ? 1 : 0
  filename         = data.archive_file.pre_signup_lambda_zip.output_path
  source_code_hash = data.archive_file.pre_signup_lambda_zip.output_base64sha256
  function_name    = "cognito-pre-signup-trigger"
  handler          = "cognito-pre-signup.handler"
  runtime          = "nodejs18.x"
  role             = aws_iam_role.pre_signup_lambda_exec.arn
  timeout          = 20
}

# --- API GATEWAY Y AUTENTICACIÓN ---
resource "aws_apigatewayv2_api" "http_api" {
  name          = var.api_name
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.api.invoke_arn
  payload_format_version = "2.0"
}

# --- RUTAS DE LA API ---

# Rutas públicas (no requieren autenticación)
resource "aws_apigatewayv2_route" "public_routes" {
  for_each = toset(["GET /products", "GET /products/{id}", "POST /products/{id}/purchase"])

  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = each.value
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Permiso para que API Gateway invoque la Lambda
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# --- SALIDAS ---
output "api_url" {
  description = "Endpoint público de la API Gateway"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "lambda_integration_id" {
  description = "The ID of the Lambda integration"
  value       = aws_apigatewayv2_integration.lambda_integration.id
}

output "api_id" {
    description = "The ID of the API Gateway"
    value = aws_apigatewayv2_api.http_api.id
}

