# Link to backend documentation: https://registry.terraform.io/modules/nozaq/remote-state-s3-backend/aws/latest
terraform {
  backend "s3" {
    bucket         = "project-363238514491-us-east-1-an"
    key            = "envs/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    kms_key_id     = "c93ada89-664e-4f3c-ac6a-c7e71d57cb1a"
    dynamodb_table = "dynamodb-table1"
  }
}