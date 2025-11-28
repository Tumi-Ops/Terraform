provider "aws" {
  region = "eu-west-1"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda.py"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "example_lambda" {
  function_name = "example-lambda"
  handler = "index.handler"
  runtime = "python3.9"
  role = aws_iam_role.iam_role_for_lambda.arn
  filename = data.archive_file.lambda_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)

  # Enable AWS X-Ray tracing
  tracing_config {
    mode = "Active"
  }
}

resource "aws_iam_role" "iam_role_for_lambda" {
  name = "iam_role_for_lambda"

  assume_role_policy = file("Policies/lambda_function_assume_role_policy.json")
  inline_policy {
    name = "iam-for-lambda"
    policy = file("Policies/lambda_function_inline_policy.json")
  }

  

  # Additional IAM role configuration
  # ...
}

# Define an API Gateway or event trigger if needed
resource "aws_api_gateway_rest_api" "serverless_api_gateway" {
  name        = "serverless_api_gateway"
  description = "API-Gateway"
}

resource "aws_api_gateway_resource" "api_gateway_resource" {
  rest_api_id = aws_api_gateway_rest_api.serverless_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.serverless_api_gateway.root_resource_id
  path_part   = "api_gateway-resource"
}

resource "aws_api_gateway_method" "example_method" {
  rest_api_id   = aws_api_gateway_rest_api.serverless_api_gateway.id
  resource_id   = aws_api_gateway_resource.api_gateway_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "initial_integration" {
  rest_api_id = aws_api_gateway_rest_api.serverless_api_gateway.id
  resource_id = aws_api_gateway_resource.api_gateway_resource.id
  http_method = aws_api_gateway_method.example_method.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.example_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "initial_deployment" {
  depends_on = [aws_api_gateway_integration.initial_integration]
  rest_api_id = aws_api_gateway_rest_api.serverless_api_gateway.id
  stage_name  = "dev"
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.serverless_api_gateway.execution_arn}/*/*"
 
}


# Additional resources like DynamoDB, S3, etc.
# ...
