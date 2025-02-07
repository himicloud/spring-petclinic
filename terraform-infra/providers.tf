# providers.tf
provider "aws" {
  region = var.aws_region # AWS region defined in the variables file
}
