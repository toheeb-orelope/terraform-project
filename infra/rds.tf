# Create an RDS subnet group for the RDS instance
resource "aws_db_subnet_group" "main_subnet_group" {
  name = "main_subnet_group"
  subnet_ids = [aws_subnet.private_subnet_1.id,
  aws_subnet.private_subnet_2.id]

  tags = {
    Name        = "My DB subnet group"
    Environment = "dev"
  }
}


# Create an RDS parameter group for the RDS instance
resource "aws_db_parameter_group" "main_parameter_group" {
  name_prefix = "my-pg"
  family      = "postgres15"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create a KMS key for encrypting RDS instances
resource "aws_kms_key" "rds_kms_key" {
  description             = "This key is used to encrypt RDS instances"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}


# Define a key policy that allows the RDS instance to use the KMS key for encryption
resource "aws_kms_key_policy" "rds_kms_key_policy" {
  key_id = aws_kms_key.rds_kms_key.id
  policy = jsonencode({
    Id = "rds-kms-policy"
    Statement = [
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      },
      {
        Sid    = "Allow RDS to use the key"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
      }
    ]
    Version = "2012-10-17"
  })
}

# Create an RDS instance
resource "aws_db_instance" "main_instance" {
  allocated_storage = 20
  storage_type      = "gp3"
  db_name           = "mydb"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro"

  username = var.db_username
  password = var.db_password

  parameter_group_name = aws_db_parameter_group.main_parameter_group.name
  db_subnet_group_name = aws_db_subnet_group.main_subnet_group.name
  skip_final_snapshot  = true
  storage_encrypted    = true
  publicly_accessible  = false

  enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade"]
  auto_minor_version_upgrade          = true
  iam_database_authentication_enabled = true
  deletion_protection                 = false
  performance_insights_enabled        = true
  performance_insights_kms_key_id     = aws_kms_key.rds_kms_key.arn
  vpc_security_group_ids              = [aws_security_group.rds_sg.id]


  tags = {
    Name        = "main_instance"
    Environment = "dev"
  }
}