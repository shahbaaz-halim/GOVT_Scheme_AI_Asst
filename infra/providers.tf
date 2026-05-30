# infra/provider.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Always pin your provider version to avoid breaking changes!
    }
  }

}

provider "aws" {
  region = var.aws_region

  # Default tags are a lifesaver. Every resource created will automatically get these.
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "Production"
      ManagedBy   = "Terraform"
    }
  }
}