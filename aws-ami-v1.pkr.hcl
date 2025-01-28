# Packer configuration for building an AMI with Ubuntu as the base
packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = "~> 1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

# Define the base AMI and configuration details for Ubuntu in us-east-1
source "amazon-ebs" "ubuntu-ami" {
  region          = "ap-south-1"
  ami_name        = "hq-ami-{{timestamp}}"
  instance_type   = "t2.micro"
  source_ami      = "ami-00bb6a80f01f03502" # Replace with the correct Ubuntu AMI ID
  ssh_username    = "ubuntu"
}

# Build configuration using Ansible for provisioning
build {
  name    = "hq-packer"
  sources = ["source.amazon-ebs.ubuntu-ami"]

  # Provisioner to run the Ansible playbook
  provisioner "ansible" {
    playbook_file = "./ansible/install_packages.yml"
  }
}
