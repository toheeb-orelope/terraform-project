# Link to backend documentation: https://registry.terraform.io/modules/nozaq/remote-state-s3-backend/aws/latest
terraform {
  backend "s3" {
    bucket         = "project-363238514491-us-east-1-an"
    key            = "envs/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    kms_key_id     = "b2948092-a0d4-4310-b838-316e430bae1f"
    dynamodb_table = "dynamodb-table1"
  }
}
