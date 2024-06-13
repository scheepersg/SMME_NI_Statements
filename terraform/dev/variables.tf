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

variable "dev_s3_bucket" {
  description = "Name of the S3 bucket for Lambda deployment"
  type        = string
}

variable "s3_bucket" {
  description = "Name of the S3 bucket for Lambda trigger"
  type        = string
}

variable "lambda_s3_key" {
  description = "S3 key for the Lambda function zip file"
  type        = string
}

variable "sns_email_endpoint" {
  description = "The email endpoint for SNS notifications"
  type        = string
}
