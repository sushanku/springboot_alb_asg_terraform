terraform {
  backend "s3" {
    bucket = "terraform-springboot-app-bucket2"
    key    = "terraform-state"
    region = "us-east-1"
    encrypt = true
  }
}