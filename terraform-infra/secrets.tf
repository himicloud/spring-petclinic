data "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id = "arn:aws:secretsmanager:ap-south-1:043309328122:secret:db-password-M6AHGu"
}
