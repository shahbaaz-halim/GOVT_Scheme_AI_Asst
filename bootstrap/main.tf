# bootstrap/main.tf

terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-2" # APAC Hyderabad region - change as needed
}

# 1. The S3 Bucket for Terraform State File
resource "aws_s3_bucket" "tf_state" {
  bucket        = "shah-ai-tf-state-bucket" # MUST be globally unique
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled" # Essential! Allows you to roll back state if something breaks
  }
}

# 2. The OIDC Provider (Tells AWS to trust GitHub tokens)
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

# 3. The IAM Role GitHub Actions will assume
resource "aws_iam_role" "github_actions_backend" {
  name = "github-actions-terraform-executor"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # ONLY allows your specific repo and main branch to assume this role
            "token.actions.githubusercontent.com:sub" = "repo:shahbaaz-halim/GOVT_Scheme_AI_Asst:*"
          }
        }
      }
    ]
  })
}

# 4. Permissions for the CI/CD Role (Admin for a personal learning account)
resource "aws_iam_role_policy_attachment" "admin_attach" {
  role       = aws_iam_role.github_actions_backend.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "state_bucket_name" {
  value = aws_s3_bucket.tf_state.id
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_backend.arn
}