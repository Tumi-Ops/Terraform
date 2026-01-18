variable "writer_lambda_function_name" {
  description = "Unique name for the writer Lambda function."
  type        = string
  default     = "birthdayWriter"
}

variable "processor_lambda_function_name" {
  description = "Unique name for the processor Lambda function."
  type        = string
  default     = "birthdayMessageProcessor"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table to store birthdays."
  type        = string
  default     = "Birthdays"
}

variable "writer_iam_policy_name" {
  description = "Name of the IAM policy for the writer Lambda function."
  type        = string
  default     = "LimitedDynamoWrite"
}

variable "processor_iam_policy_name" {
  description = "Name of the IAM policy for the processor Lambda funtion"
  type        = string
  default     = "LimitedMessageProcessor"
}

variable "writer_assume_role" {
  description = "Name of the IAM role for the writer Lambda function."
  type        = string
  default     = "dynamodb-birthday-writer"
}

variable "processor_assume_role" {
  description = "Name of the IAM role for the processor Lambda function."
  type        = string
  default     = "birthday-processor"
}