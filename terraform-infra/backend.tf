terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-syd"  # Replace with your S3 bucket name
    key            = "vpc/terraform.tfstate"  # Unique key for VPC state file
    region         = "ap-southeast-2"  # Sydney region
    dynamodb_table = "terraform-state-locks"  # DynamoDB table for state locking
    encrypt        = true
  }
}
