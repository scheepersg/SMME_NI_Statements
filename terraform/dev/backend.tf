# terraform/dev/backend.tf
terraform {
  backend "s3" {
    bucket = "your-dev-bucket"
    key    = "dev/terraform.tfstate"
    region = "your-region"
  }
}

