# AWS Region
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-south-1" # Set to Mumbai
}

# AMI ID
variable "ami_id" {
  description = "The AMI ID for the EC2 instances in the ASG"
  type        = string
  default     = "ami-0dee22c13ea7a9a67" # Replace with your specific AMI if needed
}

# Instance Type
variable "instance_type" {
  description = "The EC2 instance type for ASG instances"
  type        = string
  default     = "t2.micro" # Adjust as needed
}

# Key pair
variable "key_name" {
  description = "The name of the SSH key pair for accessing EC2 instances"
  type        = string
  default     = "my-kp-mumbai.pem"
}

# Volume Size for Root EBS Volume
variable "volume_size" {
  description = "Size of the root EBS volume in GB for the EC2 instances"
  type        = number
  default     = 20
}

# Database Name
variable "db_name" {
  description = "The name of the database to be created on the RDS instance"
  type        = string
  default     = "mydatabase" # Replace with your preferred database name
}

# Database Username
variable "db_username" {
  description = "The master username for the RDS instance"
  type        = string
  default     = "admin" # Replace with your preferred username
}

# Database Password
variable "db_password" {
  description = "The master password for the RDS instance"
  type        = string
  sensitive   = true
}

# Security Group for RDS
variable "rds_sg_name" {
  description = "The name of the security group for RDS"
  type        = string
  default     = "rds-sg"
}

# Subnet Group for RDS
variable "rds_subnet_group_name" {
  description = "The name of the RDS subnet group"
  type        = string
  default     = "rds-subnet-group"
}


