terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-mumbai"  # Replace with your bucket name
    key            = "path/to/your/terraform.tfstate"    # Replace with the desired path for the state file
    region         = "ap-south-1"                       # Mumbai region
    encrypt        = true                               # Encrypt the state file at rest
    dynamodb_table = "terraform-lock-table"             # Optional: Use DynamoDB for state locking (see step 4)
  }
}