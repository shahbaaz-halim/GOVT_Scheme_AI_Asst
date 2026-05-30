#testmain
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
  region = "ap-south-2"
}

# A lightweight, cost-effective resource to test our automated pipeline
resource "aws_dynamodb_table" "ai_session_table" {
  name         = "genai-session-metadata"
  billing_mode = "PAY_PER_REQUEST" # Serverless billing: scales down to $0.00 when not in use
  hash_key     = "SessionId"

  attribute {
    name = "SessionId"
    type = "S" # String type
  }

  tags = {
    Project     = "GenAI-AWS-Platform"
    ManagedBy   = "Terraform-CI-CD"
  }
}