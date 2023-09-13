# S3 bucket for statefile
resource "aws_s3_bucket" "my-s3-bucket" {
  bucket = var.s3_bucket
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "s3_versioning" {
  bucket = aws_s3_bucket.my-s3-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Server side encryption for S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.my-s3-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

# Dynamodb table for statelock
resource "aws_dynamodb_table" "tf-state-lock" {
  name             = var.dynamodb_table
  hash_key         = "LockID"
  billing_mode     = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}
