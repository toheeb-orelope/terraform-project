# Infra

Main application infrastructure deployed to AWS. State is stored remotely in the S3 bucket and DynamoDB table created by `bootstrap/`.

## What it provisions

| Resource | File | Description |
|----------|------|-------------|
| VPC, subnets, routing | `vpc.tf` | Isolated network for all resources |
| Security groups | `security_groups.tf` | Inbound/outbound rules |
| EC2 instance | `ec2.tf` | Application server with SSH key |
| RDS instance | `rds.tf` | Managed relational database |

## Remote Backend

State is stored in S3 with DynamoDB locking:

```
bucket  = project-363238514491-us-east-1-an
key     = envs/dev/terraform.tfstate
region  = us-east-1
encrypt = true (KMS)
```

## CI/CD

This directory is the working directory for the GitHub Actions pipeline. On every PR and push to `main` the pipeline runs `fmt`, `init`, `validate`, and `plan`. Sensitive variables (`db_password`, `db_username`, `ec2_public_key`) are injected from GitHub secrets via `TF_VAR_*` environment variables — they are never written to disk.

## Local Usage

```bash
cd infra
terraform init
terraform plan
terraform apply
```

Required variables are defined in `variables.tf`. Provide values via `terraform.tfvars` (not committed) or environment variables.

## Required Variables

| Variable | Sensitive | Description |
|----------|-----------|-------------|
| `bucket_name` | No | S3 bucket for state |
| `aws_region` | No | Target region |
| `dynamodb_table_name` | No | DynamoDB lock table |
| `account_id` | No | AWS account ID |
| `environment` | No | e.g. `dev`, `prod` |
| `kms_key_id` | Yes | KMS key for encryption |
| `my_ip_cidr` | Yes | Your IP for SSH access |
| `db_username` | Yes | RDS username |
| `db_password` | Yes | RDS password |
| `ec2_public_key` | Yes | SSH public key for EC2 |
