provider "aws" {
  region = "ap-south-1"  # Mumbai region
}

# S3 Bucket for State Storage
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state-bucket-syd"  # Ensure this is unique

  # Tags
  tags = {
    Name = "himi cloud"
  }
}

# Enable Versioning
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Cross-region replication (optional)
resource "aws_s3_bucket_replication_configuration" "terraform_state_replication" {
  depends_on = [aws_iam_role.replication_role]
  bucket     = aws_s3_bucket.terraform_state.id

  role = aws_iam_role.replication_role.arn

  rule {
    id     = "replication-rule"
    status = "Enabled"

    destination {
      bucket        = "arn:aws:s3:::my-replication-destination-bucket"  # Replace with actual destination bucket ARN
      storage_class = "STANDARD"
    }

    filter {
      prefix = ""  # Replicate all objects
    }

    delete_marker_replication {
      status = "Disabled"  # Set to "Enabled" if you want to replicate delete markers as well
    }
  }
}
