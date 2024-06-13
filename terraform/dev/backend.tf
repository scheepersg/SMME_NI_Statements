terraform {
  backend "s3" {
    bucket = "ggs-dev-bucket"  # Replace with your actual S3 bucket name
    key    = "dev/terraform.tfstate"
    region = "af-south-1"  # Replace with your actual AWS region
  }
}
