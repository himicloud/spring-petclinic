variable "aws_region" {
  default = "us-east-1"
}

variable "ami_id" {
  description = "AMI for the EC2 instance"
  default     = "ami-0866a3c8686eaeeba"  # Ubuntu
}

variable "instance_type" {
  default = "t2.micro"
}
