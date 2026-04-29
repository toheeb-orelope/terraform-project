# $HOME\.aws\credentials
# $HOME\.aws\config

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


# Create an S3 bucket with a unique name using the account ID and region
resource "aws_s3_bucket" "s3_bucket1" {
  bucket           = format("project-%s-%s-an", data.aws_caller_identity.current.account_id, data.aws_region.current.region)
  bucket_namespace = "account-regional"
  force_destroy    = true

  tags = {
    Name        = "project-bucket"
    Environment = "dev"
  }


}



# Create an SNS topic for S3 bucket notifications
resource "aws_sns_topic" "bucket_notifications" {
  name = "bucket-notifications"
}

# Configure S3 bucket notifications to send events to the SNS topic when objects are created in the "logs/" prefix
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket     = aws_s3_bucket.s3_bucket1.id
  depends_on = [aws_sns_topic_policy.bucket_notifications_policy]


  topic {
    topic_arn     = aws_sns_topic.bucket_notifications.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "logs/"
  }
}

# Create an SNS topic policy to allow S3 to publish notifications to the SNS topic
resource "aws_sns_topic_policy" "bucket_notifications_policy" {
  arn = aws_sns_topic.bucket_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3Publish"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.bucket_notifications.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.s3_bucket1.arn
          }
        }
      }
    ]
  })
}


# Enable versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "s3_bucket_versioning1" {
  bucket = aws_s3_bucket.s3_bucket1.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Create a KMS key for encrypting S3 bucket objects
resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}



# Define a key policy that allows the S3 bucket to use the KMS key for encryption
resource "aws_kms_key_policy" "s3_bucket_kms_policy1" {
  key_id = aws_kms_key.mykey.id
  policy = jsonencode({
    Id = "s3-bucket-kms-policy1"
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
        Sid    = "Allow DynamoDB to use the key"
        Effect = "Allow"
        Principal = {
          Service = "dynamodb.amazonaws.com"
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

# Configure server-side encryption for the S3 bucket using the KMS key
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_encryption1" {
  bucket = aws_s3_bucket.s3_bucket1.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "access_good_1" {
  bucket = aws_s3_bucket.s3_bucket1.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}


# Create a DynamoDB table with server-side encryption using the existing KMS key
resource "aws_dynamodb_table" "dynamodb_table1" {
  name         = "dynamodb-table1"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  point_in_time_recovery {
    enabled = true
  }

  # Define all attributes first
  attribute {
    name = "LockID"
    type = "S"
  }

  # global_secondary_index {
  #   name = "CustomerTransactionIndex"
  #   key_schema {
  #     attribute_name = "LockID"
  #     key_type       = "HASH"
  #   }
  #   projection_type = "KEYS_ONLY"
  # }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.mykey.arn
  }

  tags = {
    Environment = "dev"
    Name        = "dynamodb-table1"
  }
}
