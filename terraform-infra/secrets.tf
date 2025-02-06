# Retrieve secret metadata
data "aws_secretsmanager_secret" "db_password" {
  name = "db-password"  # Ensure this matches the secret name in AWS
}

# Retrieve the latest secret value
data "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id = data.aws_secretsmanager_secret.db_password.id
}

# Set db_password variable dynamically from AWS Secrets Manager
variable "db_password" {
  default = jsondecode(data.aws_secretsmanager_secret_version.db_password_version.secret_string)["password"]
}
