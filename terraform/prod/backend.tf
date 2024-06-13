terraform {
  backend "s3" {
    bucket = "ggs-prod-bucket"  # Replace with your actual S3 bucket name
    key    = "prod/terraform.tfstate"
    region = "af-south-1"  # Replace with your actual AWS region
  }
}
