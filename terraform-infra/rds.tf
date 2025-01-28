
# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow access to RDS from private subnets"
  vpc_id      = aws_vpc.main_vpc.id

  # Allow inbound traffic from private subnets
  ingress {
    from_port   = 3306  # Example for MySQL, adjust if using another engine
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Allow access from within the VPC
  }

  # Allow all outbound traffic (required for RDS)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

# RDS Subnet Group (to place RDS in secure subnets)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.secure_subnet_1.id, aws_subnet.secure_subnet_2.id]

  tags = {
    Name = "rds-subnet-group"
  }
}

# rds.tf

resource "aws_db_instance" "app_rds" {
  identifier          = "app-rds-instance"
  engine              = "mysql"  # Specify your preferred engine (e.g., postgres, mysql)
  instance_class      = "db.t3.micro"  # Adjust instance type as needed
  allocated_storage   = 20  # Storage in GB
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
  parameter_group_name = "default.mysql8.0"  # Use the appropriate parameter group

  multi_az            = true
  storage_encrypted   = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  # Handle final snapshot before destroying the RDS instance
  skip_final_snapshot = false
  final_snapshot_identifier = "final-snapshot-myapp"

  tags = {
    Name = "app-rds-instance"
  }
}

