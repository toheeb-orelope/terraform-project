# Data source for the DynamoDB table
data "aws_dynamodb_table" "dynamodb_table1_data" {
  name = aws_dynamodb_table.dynamodb_table1.name
}

# Data source for the S3 bucket 
data "aws_s3_bucket" "s3_bucket1_data" {
  bucket = aws_s3_bucket.s3_bucket1.bucket
}

# OUTPUTS
output "dynamodb_table_name" {
  value = data.aws_dynamodb_table.dynamodb_table1_data.name
}

output "dynamodb_table_arn" {
  value = data.aws_dynamodb_table.dynamodb_table1_data.arn
}

output "s3_bucket_name" {
  value = data.aws_s3_bucket.s3_bucket1_data.bucket
}

output "s3_bucket_arn" {
  value = data.aws_s3_bucket.s3_bucket1_data.arn
}

output "s3_bucket_regional_domain" {
  value = data.aws_s3_bucket.s3_bucket1_data.bucket_regional_domain_name
}
