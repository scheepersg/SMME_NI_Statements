provider "aws" {
  region = var.aws_region
}

# Create S3 bucket (if needed)
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.s3_bucket
  acl = "private"
}

# IAM Role for Lambda Function
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.lambda_function_name}_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for Lambda Function
resource "aws_iam_role_policy" "lambda_exec_policy" {
  name   = "${var.lambda_function_name}_exec_policy"
  role   = aws_iam_role.lambda_exec_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.dev_s3_bucket}",
          "arn:aws:s3:::${var.dev_s3_bucket}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = "sns:Publish"
        Resource = "arn:aws:sns:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${var.sns_topic_name}"
      }
    ]
  })
}

# SNS Topic
resource "aws_sns_topic" "lambda_sns_topic" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "lambda_sns_subscription" {
  topic_arn = aws_sns_topic.lambda_sns_topic.arn
  protocol  = "email"
  endpoint  = var.sns_email_endpoint
}

# Lambda Function
resource "aws_lambda_function" "example_lambda" {
  function_name = var.lambda_function_name
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_exec_role.arn
  s3_bucket     = var.dev_s3_bucket
  s3_key        = var.lambda_s3_key

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.lambda_sns_topic.arn
    }
  }

  depends_on = [aws_iam_role_policy.lambda_exec_policy]
}

# Allow S3 to trigger Lambda Function
resource "aws_lambda_permission" "s3_lambda" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.lambda_bucket.arn
}

# S3 Bucket Notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.lambda_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.example_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

data "aws_caller_identity" "current" {}

output "lambda_function_arn" {
  value = aws_lambda_function.example_lambda.arn
}
