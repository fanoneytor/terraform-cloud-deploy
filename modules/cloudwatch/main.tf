resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/backend-api"
  retention_in_days = 14
}

output "log_group" {
  value = aws_cloudwatch_log_group.lambda_logs.name
}
