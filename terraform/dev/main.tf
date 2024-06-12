provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn     = var.aws_role_arn
    session_name = "github-actions-${timestamp()}"
  }
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.s3_bucket
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_exec_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "s3:GetObject",
          "sns:Publish"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.lambda_bucket.bucket}/*",
          "arn:aws:sns:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${var.sns_topic_name}"
        ]
      }
    ]
  })
}

resource "aws_sns_topic" "lambda_sns_topic" {
  name = var.sns_topic_name
}

resource "aws_lambda_function" "s3_to_sns_lambda" {
  function_name = var.lambda_function_name
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9" # Use the latest supported Python version
  role          = aws_iam_role.lambda_exec_role.arn
  s3_bucket     = var.s3_bucket
  s3_key        = var.lambda_s3_key

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.lambda_sns_topic.arn
    }
  }

  depends_on = [aws_iam_role_policy.lambda_policy]
}

resource "aws_lambda_permission" "s3_lambda" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_to_sns_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.lambda_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.lambda_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_to_sns_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

data "aws_caller_identity" "current" {}

output "lambda_function_arn" {
  value = aws_lambda_function.s3_to_sns_lambda.arn
}

