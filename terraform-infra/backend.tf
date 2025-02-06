terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-mumbai"  # New S3 bucket in Mumbai
    key            = "vpc/terraform.tfstate"  # Unique key for VPC state file
    region         = "ap-south-1"  # Mumbai region
    dynamodb_table = "terraform-state-locks-mumbai"  # DynamoDB table for state locking
    encrypt        = true
  }
}
