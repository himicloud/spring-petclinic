variable "aws_region" {
  default = "us-east-1"
}

variable "ami_id" {
  description = "AMI for the EC2 instance"
  default     = "ami-0866a3c8686eaeeba"  # Ubuntu
}

variable "instance_type" {
  description = "Instance type for Jenkins"
  default     = "t2.medium"
}

variable "snapshot_id" {
  description = "EBS Snapshot ID for the root volume"
  default     = "snap-0cadd1c5e99c40055"
}

variable "volume_size" {
  description = "Size of the root EBS volume in GB"
  default     = 20
}
