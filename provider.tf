terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "s3tfstatebackend382518"
    key            = "statefile/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "tf-state-locks"
  }
}

provider "aws" {
  region = "us-east-1"
  # access_key = var.access_key
  # secret_key = var.secret_access_key
}
