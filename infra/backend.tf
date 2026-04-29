# Link to backend documentation: https://registry.terraform.io/modules/nozaq/remote-state-s3-backend/aws/latest
terraform {
  backend "s3" {
    bucket     = "project-363238514491-us-east-1-an"
    key        = "envs/dev/terraform.tfstate"
    region     = "us-east-1"
    encrypt    = true
    kms_key_id = "eee61541-778a-4cd7-a0c4-b14457fffe4d"
    use_lockfile = true
    # dynamodb_table = "dynamodb-table1"
  }
}
