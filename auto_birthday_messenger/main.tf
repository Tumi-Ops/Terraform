# DynamoDB Table to store birthday records
#################################################################
resource "aws_dynamodb_table" "birthdays_dynamodb_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "email"
  range_key    = "created_at"

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  tags = {
    Name        = "auto-birthday-wisher"
    Environment = "dev"
  }
}
###################################################################


# IAM Role and Policy for Lambda Writer Function
# #################################################################
resource "aws_iam_role_policy" "dynamo_iam_policy" {
  name = var.writer_iam_policy_name
  role = aws_iam_role.writer_assume_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Statement1",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:PutItem"
        ],
        "Resource" : [
          aws_dynamodb_table.birthdays_dynamodb_table.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role" "writer_assume_role" {
  name = var.writer_assume_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "auto-birthday-wisher"
    Environment = "dev"
  }
}
##################################################################


# IAM Role and Policy for Lambda Processor Function
##################################################################
resource "aws_iam_role_policy" "processor_iam_policy" { # Subject to change
  name = var.processor_iam_policy_name
  role = aws_iam_role.processor_assume_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Statement1",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:Scan",
          "dynamodb:UpdateItem",
          "bedrock:InvokeModel",
          "secretsmanager:GetSecretValue"
        ],
        "Resource" : [
          "arn:aws:bedrock:us-east-1::foundation-model/amazon.nova-lite-v1:0",
          aws_dynamodb_table.birthdays_dynamodb_table.arn,
          "arn:aws:secretsmanager:eu-central-1:408852977582:secret:dev/email-creds-6o2unk"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "processor_assume_role" {
  name = var.processor_assume_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "auto-birthday-wisher"
    Environment = "dev"
  }
}
##################################################################


# AWS Managed Policy Attachments to IAM roles for CloudWatch Logs
# #################################################################
resource "aws_iam_role_policy_attachment" "writer_lambda_logs" {
  role       = aws_iam_role.writer_assume_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "processor_lambda_logs" {
  role       = aws_iam_role.processor_assume_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
##################################################################

# Lambda Functions
##################################################################
resource "aws_lambda_function" "writer_function" {
  filename      = "birthdayWriter-function.zip"
  function_name = var.writer_lambda_function_name
  role          = aws_iam_role.writer_assume_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.14"
  architectures = ["x86_64"]

  description = "Lambda function to write birthday records to DynamoDB."

  memory_size = 128
  timeout     = 30

  # Advanced logging configuration
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "WARN"
  }

  # Ensure IAM role and log group are ready
  depends_on = [
    aws_iam_role.writer_assume_role, aws_iam_role_policy_attachment.writer_lambda_logs
  ]

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }

  tags = {
    Name        = "auto-birthday-wisher"
    Environment = "dev"
  }
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.writer_function.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
  depends_on    = [aws_apigatewayv2_api.http_api]
}


resource "aws_lambda_function" "processor_function" {
  filename      = "birthdayMessageProcessor-function.zip"
  function_name = var.processor_lambda_function_name
  role          = aws_iam_role.processor_assume_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.14"
  architectures = ["x86_64"]

  description = "Processes birthday messages and sends wishes."

  memory_size = 128
  timeout     = 60

  # Advanced logging configuration
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "WARN"
  }

  # Ensure IAM role and log group are ready
  depends_on = [
    aws_iam_role.processor_assume_role, aws_iam_role_policy_attachment.processor_lambda_logs
  ]

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }

  tags = {
    Name        = "auto-birthday-wisher"
    Environment = "dev"
  }
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.processor_rule.arn
  depends_on    = [aws_cloudwatch_event_rule.processor_rule]
}

###################################################################


# API Gateway to send data from app and trigger Lambda Writer Function
##################################################################
resource "aws_apigatewayv2_api" "http_api" {
  name            = "birthdays-api"
  protocol_type   = "HTTP"
  ip_address_type = "dualstack"
  description     = "API Gateway to accept birthday records and trigger Lambda writer function."
  tags = {
    Name        = "auto-birthday-wisher"
    Environment = "dev"
  }
}

resource "aws_apigatewayv2_integration" "api_gateway_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"

  connection_type    = "INTERNET"
  description        = "API Gateway integration with Lambda writer function"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.writer_function.arn
  # passthrough_behavior = "WHEN_NO_MATCH"

  payload_format_version = "2.0"

  depends_on = [aws_lambda_function.writer_function, aws_apigatewayv2_api.http_api]
}

resource "aws_apigatewayv2_route" "api_gateway_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /birthdays"

  target     = "integrations/${aws_apigatewayv2_integration.api_gateway_integration.id}"
  depends_on = [aws_apigatewayv2_api.http_api]
}

resource "aws_apigatewayv2_stage" "api_gateway_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_deployment" "api_gateway_deployment" {
  api_id = aws_apigatewayv2_api.http_api.id

  lifecycle {
    create_before_destroy = true
  }

  triggers = {
    redeployment = sha1(jsonencode(aws_apigatewayv2_api.http_api))
  }

  depends_on = [aws_apigatewayv2_api.http_api,
    aws_apigatewayv2_integration.api_gateway_integration,
  aws_apigatewayv2_route.api_gateway_route]
}
###################################################################


# EventBrdge(CloudWatch Event Rule) to invoke the messsage processor Lambda
###################################################################
resource "aws_cloudwatch_event_rule" "processor_rule" {
  name        = "message-processor-rule"
  description = "Triggers the message processor Lambda every day at 10 AM UTC."

  schedule_expression = "cron(0 10 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.processor_rule.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.processor_function.arn
}
###################################################################
# Log format for api gateway logging(Activated after deployment)
# { "requestId":"$context.requestId", 
# "ip": "$context.identity.sourceIp", "requestTime":"$context.requestTime", "httpMethod":"$context.httpMethod",
# "routeKey":"$context.routeKey", "status":"$context.status","protocol":"$context.protocol", 
# "responseLength":"$context.responseLength", "integration error": "$context.integration.error" , 
# "Integration error message":"$context.integrationErrorMessage", "error":"$context.error.message", 
# "responseType":"$context.error.responseType", "message string":"$context.error.messageString"