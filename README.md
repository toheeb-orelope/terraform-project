# Terraform Project

AWS infrastructure provisioned with Terraform, deployed via a GitHub Actions CI/CD pipeline using OIDC authentication (no long-lived credentials).

## Repository Structure

| Directory | Purpose |
|-----------|---------|
| `bootstrap/` | One-time setup — creates the S3 bucket, DynamoDB table, and KMS key used as the Terraform remote backend |
| `infra/` | Main infrastructure — VPC, EC2, RDS, and security groups deployed to the remote backend |
| `.github/workflows/` | CI/CD pipeline definition |

## CI/CD Pipeline

The pipeline runs on every pull request and push to `main`.

**Authentication:** GitHub Actions assumes an IAM role via OIDC — no AWS access keys are stored in GitHub secrets.

**Steps:**

1. `terraform fmt -check` — enforces formatting
2. `terraform init` — initialises the S3 remote backend
3. `terraform validate` — checks configuration syntax
4. `terraform plan -input=false` — previews changes

**Secrets required in GitHub:**

| Secret | Description |
|--------|-------------|
| `EC2_PUBLIC_KEY` | SSH public key for the EC2 instance |
| `DB_PASSWORD` | RDS database password |
| `DB_USERNAME` | RDS database username |

**Variables required in GitHub (`vars.`):**

| Variable | Description |
|----------|-------------|
| `AWS_ROLE_ARN` | IAM role ARN assumed via OIDC |
| `AWS_REGION` | Target AWS region |

## Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured locally for `bootstrap` runs
- OIDC trust relationship configured between GitHub Actions and the IAM role
