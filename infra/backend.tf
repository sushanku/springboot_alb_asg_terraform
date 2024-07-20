terraform {
  backend "s3" {
    bucket = "terraform-springboot-app-bucket"
    key    = "terraform-state"
    region = "us-east-1"
    encrypt = true
  }
}