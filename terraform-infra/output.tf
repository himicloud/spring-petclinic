output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.app_lb.dns_name
}

output "rds_endpoint" {
  description = "RDS endpoint URL"
  value       = aws_db_instance.app_rds.endpoint
}

output "vpc_id" {
  description = "ID of the main VPC"
  value       = aws_vpc.main_vpc.id
}
