terraform {
  backend "s3" {
    bucket = "your-prod-bucket"
    key    = "prod/terraform.tfstate"
    region = "your-region"
  }
}

