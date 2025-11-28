#  resource "aws_dynamodb_table" "DynamoLists-meh2szflhvearkr3spbtrkmjim-listdev" {
#   name           = "DynamoLists-meh2szflhvearkr3spbtrkmjim-listdev"
#   billing_mode   = "PROVISIONED"
#   hash_key       = "id"
#   read_capacity  = 5
#   write_capacity = 5

#   // Enable X-Ray tracing for DynamoDB
#   server_side_encryption {
#     enabled = true
#   }

#   // Additional configuration
#   attribute {
#     name = "id"
#     type = "S"
#   }

#   attribute {
#     name = "_email"
#     type = "S"
#   }

#   attribute {
#     name = "_list_name"
#     type = "S"
#   }

#   attribute {
#     name = "_total"
#     type = "S"
#   }


#   # Global secondary index
#   global_secondary_index {
#     name = "exampleGSI"
#     hash_key = "gsi_key"
#     range_key = "gsi_range"
#     projection_type = "INCLUDE"
#     non_key_attributes = ["extra_attribute"]
#     read_capacity = 5
#     write_capacity = 5
#   }
// }
