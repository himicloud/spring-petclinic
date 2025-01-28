terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-mumbai"
    key            = "path/to/your/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"  # Add this line
  }
}