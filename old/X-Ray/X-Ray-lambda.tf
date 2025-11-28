# provider "aws" {
#   region = "eu-west-1"
# }

# resource "aws_lambda_function" "example_lambda" {
#   function_name = "example-lambda"
#   handler = "index.handler"
#   role = aws_iam_role.example_role.arn
#   runtime = "nodejs14.x"
  
# // Enable X-Ray tracing for the Lambda function
#   tracing_config {
#     mode = "Active"
#   }

# }

# resource "aws_iam_role" "example_role" {
#   name = "example-role"
  
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }






