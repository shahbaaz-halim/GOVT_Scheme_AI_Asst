# ------------------------------------------------------
# 1. Document Ingestion Bucket (Raw PDFs for Bedrock)
# ------------------------------------------------------
resource "aws_s3_bucket" "raw_docs" {
  bucket        = "${var.project_name}-raw-docs"
  force_destroy = true # Essential for solo dev: lets you run 'terraform destroy' even if there are files inside.
}

# Absolute Security: Block all public access
resource "aws_s3_bucket_public_access_block" "raw_docs_security" {
  bucket                  = aws_s3_bucket.raw_docs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ------------------------------------------------------
# 2. Audio Asset Storage (Amazon Polly Outputs)
# ------------------------------------------------------
resource "aws_s3_bucket" "audio_output" {
  bucket        = "${var.project_name}-audio-output"
  force_destroy = true
}

# Absolute Security: Block all public access
resource "aws_s3_bucket_public_access_block" "audio_output_security" {
  bucket                  = aws_s3_bucket.audio_output.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Cost-Saving Measure: Automatically delete audio files after 1 day
resource "aws_s3_bucket_lifecycle_configuration" "audio_cleanup" {
  bucket = aws_s3_bucket.audio_output.id

  rule {
    id     = "delete-stale-audio"
    status = "Enabled"
    
    filter {}
    
    expiration {
      days = 1
    }
  }
}