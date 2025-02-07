
# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Main VPC"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet 1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet 2"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "Private Subnet 1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "Private Subnet 2"
  }
}

# Secure Subnets
resource "aws_subnet" "secure_subnet_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "Secure Subnet 1"
  }
}

resource "aws_subnet" "secure_subnet_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "Secure Subnet 2"
  }
}

# Internet Gateway for Public Subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Main Internet Gateway"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# Associate Public Route Table with Public Subnets
resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Security Group for the ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP access to ALB"
  vpc_id      = aws_vpc.main_vpc.id

  # Allow inbound HTTP traffic to ALB
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic from ALB
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "app-load-balancer"
  }
}

# Target Group for ALB
resource "aws_lb_target_group" "app_tg" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "app-target-group"
  }
}

# Listener for ALB
resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Launch Template for ASG instances
resource "aws_launch_template" "app_launch_template" {
  name_prefix   = "app-launch-template"
  image_id      = var.ami_id        # Replace with your desired AMI ID or variable
  instance_type = var.instance_type # Instance type, e.g., "t2.micro" or "t2.medium"
  key_name      = var.key_name      # Replace with your key pair name

  # Attach security group to allow necessary traffic
  vpc_security_group_ids = [aws_security_group.private_instance_sg.id]

  # User Data script (Optional: Example for installing Docker or app)
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ASG-Instance"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn] # Link to the ALB target group

  health_check_type         = "EC2"
  health_check_grace_period = 300

  # Define tags correctly using tag blocks
  tag {
    key                 = "Name"
    value               = "ASG-Instance"
    propagate_at_launch = true
  }
}

# Security Group for ASG Instances
resource "aws_security_group" "private_instance_sg" {
  name        = "private-instance-sg"
  description = "Allow traffic from ALB to instances"
  vpc_id      = aws_vpc.main_vpc.id

  # Allow inbound HTTP traffic from ALB security group
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-instance-sg"
  }
}
