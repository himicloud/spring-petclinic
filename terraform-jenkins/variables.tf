variable "aws_region" {
  default = "ap-south-1"
}

variable "ami_id" {
  description = "AMI for the EC2 instance"
  default     = "ami-0dee22c13ea7a9a67"  # Ubuntu
}

variable "instance_type" {
  description = "Instance type for Jenkins"
  default     = "t2.large"
}

variable "volume_size" {
  description = "Size of the root EBS volume in GB"
  default     = 50
}
