################################
# 작성일: 25.01.16
# 작성자: pangkin
# s3 backend 구성
################################

provider "aws" {
  region = "us-east-2"
}

# S3 버킷 설정
resource "aws_s3_bucket" "my_terraform_state" {
  bucket        = "bucket-ajj-09999"
  force_destroy = true

  tags = {
    Name = "My bucket"
  }
}

resource "aws_s3_bucket_versioning" "my_terraform_state" {
  bucket = aws_s3_bucket.my_terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "my_terraform_state" {
  bucket = aws_s3_bucket.my_terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "my_terraform_state_restriced" {
  bucket = aws_s3_bucket.my_terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# Dynamodb 설정
resource "aws_dynamodb_table" "my_terraform_locks" {
  name         = "myTFLocks-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
