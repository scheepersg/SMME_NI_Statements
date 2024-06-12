variable "aws_region" {
  description = "The AWS region"
  type        = string
}

variable "aws_role_arn" {
  description = "The ARN of the IAM role"
  type        = string
}

variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "s3_bucket" {
  description = "The S3 bucket for the Lambda function code and events"
  type        = string
}

variable "lambda_s3_key" {
  description = "The S3 key for the Lambda function code"
  type        = string
}

variable "sns_topic_name" {
  description = "The name of the SNS topic"
  type        = string
}

