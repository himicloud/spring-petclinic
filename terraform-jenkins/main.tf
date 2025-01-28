provider "aws" {
  region = var.aws_region
}

# Data source to get the default VPC
data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and HTTP access"
  vpc_id      = data.aws_vpc.default.id  # Reference the default VPC ID directly

  # Allowing SSH access on port 22
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # You can restrict this to your IP for better security
  }

  # Allowing HTTP access on port 8080
  ingress {
    description = "Allow HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule for all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins" {
  ami             = var.ami_id
  instance_type   = var.instance_type  # Reference the instance type variable
  key_name        = "my-kp-mumbai" # Add your key pair here
  security_groups = [aws_security_group.jenkins_sg.name]

  # Configure root volume with specified volume size
  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size  # Reference the volume size variable
  }

  tags = {
    Name = "Jenkins-Server"
  }
}
