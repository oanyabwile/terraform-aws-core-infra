
# KMS – RDS Master Password Encryption

resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS master password"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name      = "${var.name}-rds-kms"
    ManagedBy = "Terraform"
    Purpose   = "RDS master password encryption"
  }
}

resource "aws_kms_alias" "rds" {
  name          = "alias/rds-master-password"
  target_key_id = aws_kms_key.rds.key_id
}

# DB Subnet Group (Private Subnets Only)


resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name      = "${var.name}-db-subnet-group"
    ManagedBy = "Terraform"
  }
}

# RDS PostgreSQL Instance


resource "aws_db_instance" "this" {
  identifier = "${var.name}-db"

  engine         = "postgres"
  engine_version = "15.15"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username

  # Secrets Manager–managed password
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.rds.arn

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_sg_id]

  publicly_accessible = false

  # Safe, in-place improvements
  backup_retention_period = 7
  deletion_protection     = false
  skip_final_snapshot     = true

}

# Secrets Manager Rotation 

resource "aws_secretsmanager_secret_rotation" "rds" {
  secret_id = aws_db_instance.this.master_user_secret[0].secret_arn

  rotation_rules {
    automatically_after_days = 30
  }
}
