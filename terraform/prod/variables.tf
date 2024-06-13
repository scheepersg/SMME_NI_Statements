variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "sns_topic_name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "s3_bucket" {
  description = "Name of the S3 bucket for Lambda deployment"
  type        = string
}

variable "lambda_s3_key" {
  description = "S3 key for the Lambda function zip file"
  type        = string
}
