resource "aws_dynamodb_table" "flightsyte-dynamodb-table" {
  name           = "Flightsyte_DynamoDB"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "email"
  range_key      = "username"

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "username"
    type = "S"
  }

  tags = {
    Name        = "flightsyte-dynamodb-table"
    Environment = "development"
  }
}